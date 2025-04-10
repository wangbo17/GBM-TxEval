# ui/mod_step5.R

mod_step5_ui <- function(id) {
  ns <- NS(id)

  sidebarLayout(
    sidebarPanel(
      h4("Step 5: Process Data"),
      p(strong("Run Gene Set Enrichment Analysis (GSEA) and PC1 projection")),

      # Normalization method block
      wellPanel(
        style = "padding: 15px 10px 5px 10px; margin-bottom: 5px;",
        h5("Normalization Method"),
        uiOutput(ns("norm_ui"))
      ),

      # Expression filtering threshold with tooltip
      wellPanel(
        style = "padding: 15px 10px 5px 10px; margin-bottom: 5px;",
        h5("Low Expression Filter"),
        tagList(
          p("Retain genes expressed above the 25th percentile (Q1) in at least the specified proportion of 'Untreated' or 'Treated' samples."),
          sliderInput(
            ns("prop_thresh"),
            label = NULL,
            min = 0,
            max = 1,
            value = 1,
            step = 0.05
          )
        )
      ),

      # Gene set type block
      wellPanel(
        style = "padding: 15px 10px 5px 10px; margin-bottom: 5px;",
        h5("Gene Set Type"),
        p("Select a gene set format that matches your expression matrix:"),
        radioButtons(
          ns("gene_set_choice"),
          label = NULL,
          choices = c("Ensembl IDs (recommended)" = "ensembl", "HGNC Gene Symbols" = "symbol"),
          selected = "ensembl"
        )
      ),

      # Action buttons
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
