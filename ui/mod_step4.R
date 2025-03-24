# ui/mod_step4.R

mod_step4_ui <- function(id) {
  ns <- NS(id)

  sidebarLayout(
    sidebarPanel(
      h4("Define Filtering Criteria"),
      uiOutput(ns("filter_options")),
      br(),
      fluidRow(
        column(6, actionButton(ns("to_step3"), "Back", class = "btn-secondary")),
        column(6, actionButton(ns("to_step5"), "Next", class = "btn-primary"))
      )
    ),
    mainPanel(
      h4("Filtered Metadata Preview"),
      DTOutput(ns("filtered_preview")),
      br(),
      div(
        style = "text-align: right;",
        downloadButton(ns("download_colData"), "Download Filtered Metadata", class = "btn-success"),
        downloadButton(ns("download_countData"), "Download Filtered Gene Expression Matrix", class = "btn-success")
      )
    )
  )
}
