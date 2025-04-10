# ui/mod_step1_ui.R

mod_step1_ui <- function(id) {
  ns <- NS(id)

  sidebarLayout(
    sidebarPanel(
      tags$h4("Overview & Upload Datasets"),

      tags$div(style = "height: 6px;"),
      tags$div(
        style = "background-color: #E5E5EA; padding: 12px; border-radius: 10px; margin-bottom: 12px; font-size: 16px; line-height: 1.5; color: #1D1D1F;",
        tags$p(strong("About GBM-TxEval:"), style = "margin-bottom: 4px; color: #3A3A3C;"),
        tags$p(
          "This tool enables the transcriptional stratification of glioblastoma (GBM) based on paired gene expression profiles. It facilitates the analysis of treatment-induced transcriptional changes and supports the identification of suitable preclinical models for precision therapy development.",
          style = "margin-top: 0; margin-bottom: 2px;"
        )
      ),

      tags$div(style = "height: 6px;"),
      fileInput(ns("meta_file"), "Upload Sample Metadata (CSV)", accept = ".csv"),
      fileInput(ns("raw_data_file"), "Upload Gene Expression Matrix (CSV, Max 2GB)", accept = ".csv"),

      selectInput(
        ns("manual_expr_type"),
        label = "Expression Data Type (auto-detected; override optional):",
        choices = c("Auto"),
        selected = "Auto",
        width = "100%"
      ),

      actionButton(ns("to_step2"), "Next", class = "btn-primary", style = "margin-top: 10px;", disabled = TRUE)
    ),

    mainPanel(
      tags$style(HTML("
        .example-table,
        .example-table thead,
        .example-table tbody,
        .example-table th,
        .example-table td {
          background-color: transparent !important;
        }
        .example-table {
          font-size: 15px;
          line-height: 1.2;
          width: auto;
          margin-bottom: 10px;
        }
        .example-table th, .example-table td {
          padding: 4px 8px;
        }
        .example-table td.numeric {
          text-align: right;
        }
      ")),

      tags$div(
        style = "background-color: #f9f9f9; padding: 15px; border-radius: 8px; box-shadow: 0 0 5px rgba(0,0,0,0.1);",
        tags$h4("Instructions"),

        tags$h5("Sample Metadata Requirements"),
        tags$ul(
          tags$li("Each row must represent one biological sample."),
          tags$li("Each column should describe a sample attribute (e.g., Sample, Donor, Model, Condition)."),
          tags$li("Sample IDs must match those in the expression matrix.")
        ),
        tags$div(
          style = "margin-left: 60px;",
          tags$table(
            class = "table table-bordered example-table",
            tags$thead(
              tags$tr(
                tags$th("Sample"),
                tags$th("Donor"),
                tags$th("Model"),
                tags$th("Condition"),
                tags$th("...")
              )
            ),
            tags$tbody(
              tags$tr(
                tags$td("S1_U"),
                tags$td("D1"),
                tags$td("GBM63"),
                tags$td("Untreated"),
                tags$td("...")
              ),
              tags$tr(
                tags$td("S1_T"),
                tags$td("D1"),
                tags$td("GBM63"),
                tags$td("Treated"),
                tags$td("...")
              )
            )
          )
        ),

        tags$h5("Gene Expression Matrix Requirements"),
        tags$ul(
          tags$li("Rows represent genes (e.g., Ensembl IDs or Gene Symbols)."),
          tags$li("Columns represent samples; column names must match sample IDs in metadata."),
          tags$li("Values can be raw read counts, FPKM, or TPM.")
        ),
        tags$div(
          style = "margin-left: 60px;",
          tags$table(
            class = "table table-bordered example-table",
            tags$thead(
              tags$tr(
                tags$th("GeneID"),
                tags$th("S1_U", style = "text-align: right;"),
                tags$th("S1_T", style = "text-align: right;")
              )
            ),
            tags$tbody(
              tags$tr(
                tags$td("ENSG00000000419"),
                tags$td(class = "numeric", "98"),
                tags$td(class = "numeric", "90")
              ),
              tags$tr(
                tags$td("ENSG00000000457"),
                tags$td(class = "numeric", "4"),
                tags$td(class = "numeric", "5")
              ),
              tags$tr(
                tags$td("ENSG00000001036"),
                tags$td(class = "numeric", "39"),
                tags$td(class = "numeric", "13")
              )
            )
          )
        )
      ),

      tags$hr(),
      tags$h5("Upload Status and Expression Data Type", style = "font-style: italic;"),
      verbatimTextOutput(ns("upload_status"), placeholder = TRUE)
    )
  )
}
