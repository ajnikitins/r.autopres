#' @exportS3Method knitr::knit_print
knit_print.data.frame <- function(x, options, ...) {
  res <- paste("Processed chart in slide:", options$label)

  structure(res, class = "knit_asis", knit_meta = list(x))
}

#' Rmarkdown Document Format For Automated Powerpoint Presentations
#'
#' @param base_ppt Path to the template presentation
#' @param ... Other arguments to html_document
#'
#' @return An output format to be used in .Rmd documents
#' @export
autoppt_format <- function(base_ppt = NULL, ...) {

  pre_processor <- \(metadata, input_file, runtime, knit_meta, files_dir, output_dir) {
    message(paste("opening template presentation:", base_ppt), "\n")

    output_file <- paste0(output_dir, "/", stringr::str_remove(input_file, stringr::fixed(".knit.md")), ".", format(Sys.time(), "%Y-%m-%d.%H-%M-%S"), ".pptx")
    file.copy(base_ppt, output_file)

    # Process data frames in knitr metadata for writing to the presentation
    # knit_meta_id represents the chunk label, i.e., the slide
    slides <- attr(knit_meta, "knit_meta_id")
    lapply(seq_along(unique(slides)), \(slide_id) {
      slide <- unique(slides)[[slide_id]]
      slide_chart_data <- knit_meta[slides == slide]

      lapply(seq_along(slide_chart_data), \(chart_id) {
        message(paste("changing data: slide", slide_id, "chart", chart_id), "\n")
        replace_chart_data(output_file, output_file, slide_id, chart_id, slide_chart_data[[chart_id]])
      })
    })

    NULL
  }

  rmarkdown::output_format(
    knitr = NULL,
    pandoc = NULL,
    pre_processor = pre_processor,
    base_format = rmarkdown::html_document(...)
  )
}
