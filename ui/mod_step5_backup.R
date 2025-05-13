# ui/mod_step5.R

mod_step5_ui <- function(id) {
  ns <- NS(id)

  sidebarLayout(
    sidebarPanel(
      h4("Process Data for Filtered Donors"),
      br(),

      uiOutput(ns("norm_ui")),
      br(),

      radioButtons(
        ns("gene_set_choice"),
        label = "Select Gene Set Type:",
        choices = c("Ensembl IDs (recommended)" = "ensembl", "HGNC Gene Symbols" = "symbol"),
        selected = "ensembl"
      ),
      br(),

      fluidRow(
        column(6,
          actionButton(
            ns("start_processing"),
            "Start Processing",
            class = "btn-processing",
            style = "width: 100%; font-weight: bold;"
          )
        )
      ),
      br(),

      fluidRow(
        column(6, actionButton(ns("to_step4"), "Back", class = "btn-secondary")),
        column(6, actionButton(ns("to_step6"), "Next", class = "btn-primary", disabled = TRUE))
      )
    ),

    mainPanel(
      h4("Results Preview"),
      DTOutput(ns("processed_results")),
      br(),
      div(style = "text-align: right;", uiOutput(ns("download_results_ui")))
    )
  )
}
