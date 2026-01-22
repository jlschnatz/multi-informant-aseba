#' @title Create a nice table using the `tinytable` package
#' @param x A dataframe.
#' @param caption The caption of the table.
#' @param note A note for the table.
#' @param column_names The columns names of the table.
nice_table <- function(
  x,
  #caption = NULL,
  note = NULL,
  col_names,
  format = c("html", "markdown", "latex", "typst")
) {
  if (!is.null(note)) {
    note <- paste0("_Note_. ", note)
  }
  format <- match.arg(format)
  tab <- tinytable::tt(
    x = x,
    # caption = caption,
    notes = note,
    width = 1
  ) |>
    tinytable::style_tt(align = "c") |>
    tinytable::style_tt(j = 1, i = 1:nrow(x), align = "l")
  colnames(tab) <- col_names
  tab
}
