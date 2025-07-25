#' Process data for plotting
#'
#' @param data data frame
#' @param categories column names (or indexes) which will be mapped as categories (e.g., x-axis)
#' @param series column names (or indexes) which will be mapped as series (e.g., y-axis)
#' @param date_fmt Excel data format string (e.g., "mm/yy")
#' @param return_all Should columns besides categories and series be returned
#' @param clean_categories Whether repeating categories should be replaced with NA (Excel usually needs this)
#' @param space_categories_at After which category level to add blank rows
#'
#' @return A formatted `chart_data` object with set `category`, `series`, `data_fmt` attributes
#' @export
#'
format_chart_data <- function(data, categories = NULL, series = NULL, date_fmt = "mm/yy", return_all = FALSE, clean_categories = FALSE, space_categories_at = FALSE) {
  stopifnot(length(data) > 0)

  if (is.null(series) && is.null(categories)) {
    if (length(data) == 1) {
      categories <-  NULL
      series <- 1
    } else {
      categories <- 1
      series <- seq_along(data)[-1]
    }
  }

  stopifnot(!is.null(series))

  if (is.numeric(categories)) {
    stopifnot(all(categories < length(data)))
    categories <- names(data)[categories]
  }

  if (is.numeric(series)) {
    stopifnot(all(series <= length(data)))
    series <- names(data)[series]
  }

  data <- data %>%
    dplyr::relocate(dplyr::all_of(c(categories, series)))

  if (!return_all) {
    data <- data %>%
      dplyr::select(dplyr::all_of(c(categories, series)))
  }

  # TODO: Add tidyselect
  stopifnot(all(sapply(data[, c(categories, series)], is.atomic)))
  # stopifnot(all(summarise(data, across(c({{categories_from}}, {{series_from}}), is.atomic))))

  # categories <- data %>%
  #   dplyr::select({{categories_from}})
  #
  # series <- data %>%
  #   dplyr::select({{series_from}})

  # Add empty rows after the specified lowest category
  # If TRUE, select penultimate category
  if ((is.logical(space_categories_at) && space_categories_at)) {
    space_categories_at <- length(categories) - 1
  }
  if (is.character(space_categories_at)) {
    space_categories_at <- match(space_categories_at, categories)
  }
  if (is.numeric(space_categories_at)) {
    stopifnot(length(space_categories_at) == 1)
    stopifnot(!is.numeric(space_categories_at) || space_categories_at <= length(categories))

    data <- data %>%
      dplyr::group_by(dplyr::across(dplyr::all_of(1:space_categories_at))) %>%
      dplyr::group_modify(~ dplyr::add_row(.x)) %>%
      dplyr::ungroup() %>%
      dplyr::slice(1:(dplyr::n() - 1))
  }

  # Clean categories by NAing values that repeat the previous one
  if ((is.logical(clean_categories) && clean_categories)) {
    clean_categories <- categories[-length(categories)]
  }
  if (is.numeric(clean_categories) || is.character(clean_categories)) {
    data <- data %>%
      tidyr::fill(dplyr::all_of(clean_categories)) %>%
      dplyr::mutate(dplyr::across(dplyr::all_of(clean_categories), function(x) {
        x[x == dplyr::lag(x)] <- NA
        x
      }
      ))
  }

  attr(data, "categories") <- categories
  attr(data, "series") <- series
  attr(data, "date_fmt") <- date_fmt

  class(data) <- c("chart_data", class(data))

  data
}

#' Replace PowerPoint chart data
#'
#' @param input_ppt Path to input presentation
#' @param output_ppt Path to output presentation
#' @param slide_index Index of slide
#' @param chart_index Index of chart
#' @param chart_data Data frame with new chart data (preferably `chart_data`)
#'
#' @return NULL
#' @export
#'
replace_chart_data <- function(input_ppt, output_ppt, slide_index, chart_index, chart_data) {
  if (length(chart_data) == 0) {
    stop("Replacement data does not exist.")
  }
  # Format data if not done already
  if (!("chart_data" %in% class(chart_data))) {
    chart_data <- format_chart_data(chart_data)
  }

  date_fmt <- attr(chart_data, "date_fmt")

  withr::local_options(list("openxlsx2.dateFormat" = stringr::str_replace(date_fmt, stringr::fixed("/"), "\\/")))

  # Fix date vector NAs not being convertible to Python
  chart_data_fix <- dplyr::mutate(chart_data, dplyr::across(dplyr::where(lubridate::is.Date), ~ tidyr::replace_na(.x, lubridate::as_date(-25567))))

  # Load python code
  reticulate::source_python(system.file("python", "replace_data.py", package = "r.autopres"))
  py_replace_data(input_ppt, slide_index, chart_index, chart_data_fix, attr(chart_data, "categories"), attr(chart_data, "series"), output_file = output_ppt)
}
