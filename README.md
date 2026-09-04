# r.autopres

## Description

`r.autopres` is an R package with tools for automating PowerPoint presentations. Its main purpose is to update the embedded data of existing PowerPoint charts directly from R.

The main functions are:

* `format_chart_data()` – prepares an R data frame for use in PowerPoint charts

  * supports separate category and series columns
  * supports multi-level categories
  * allows Excel date formats to be specified
* `replace_chart_data()` – replaces the embedded data of an existing PowerPoint chart with an R data frame
* `autoppt_format()` – an R Markdown output format for generating updated PowerPoint presentations from a template

The package uses Python through `reticulate` for modifying PowerPoint chart data.

## Installation

`r.autopres` requires Python together with the `pandas` and `python-pptx` packages.

```r
# install.packages("remotes")
remotes::install_github("ajnikitins/r.autopres")
```

If R does not automatically detect the desired Python installation, it can be configured through `reticulate` or in RStudio under:

```text
Tools > Global Options > Python
```

## Replacing PowerPoint chart data

`replace_chart_data()` updates the data embedded in an existing PowerPoint chart while preserving the chart itself and its formatting.

For example:

```r
library(r.autopres)

data <- data.frame(
  date = as.Date(c("2024-01-01", "2024-02-01", "2024-03-01")),
  series_a = c(1.2, 1.5, 1.7),
  series_b = c(0.8, 1.1, 1.3)
)

chart_data <- format_chart_data(
  data,
  categories = "date",
  series = c("series_a", "series_b"),
  date_fmt = "mmm-yy"
)

replace_chart_data(
  input_ppt = "presentation.pptx",
  output_ppt = "presentation_updated.pptx",
  slide_index = 1,
  chart_index = 1,
  chart_data = chart_data
)
```

`format_chart_data()` can also be used to prepare charts with multiple category levels or to control how repeated category labels are written to the embedded Excel workbook.

## Automated presentations with R Markdown

`autoppt_format()` provides an R Markdown output format for updating an entire PowerPoint presentation from a template.

A template presentation is supplied through `base_ppt`. Each labelled R Markdown chunk corresponds to a slide, and data frames printed within the chunk are used to replace the data in that slide's charts.

For example, an R Markdown document can use:

```yaml
---
output:
  r.autopres::autoppt_format:
    base_ppt: "template.pptx"
---
```

and contain:

````markdown
```{r slide_1}
format_chart_data(
  data,
  categories = "date",
  series = c("series_a", "series_b")
)
```
````

When the document is rendered, `r.autopres` copies the template presentation and replaces the corresponding chart data with the data produced in R.

This allows recurring presentations to retain their existing PowerPoint formatting while updating the underlying data programmatically.

## Acknowledgements

* Artūrs Jānis Ņikitins – package author
* Colleagues at Latvijas Banka
