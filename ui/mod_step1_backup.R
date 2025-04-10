# ui/mod_step1_ui.R

mod_step1_ui <- function(id) {
  ns <- NS(id)

  sidebarLayout(
    sidebarPanel(
      tags$h4("Upload Datasets"),
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
      tags$div(
        style = "background-color: #f9f9f9; padding: 15px; border-radius: 8px; box-shadow: 0 0 5px rgba(0,0,0,0.1);",
        tags$h4("Instructions"),
        h5("Sample Metadata Requirements"),
        tags$ul(
          tags$li("Each row represents a sample."),
          tags$li("Each column contains sample attributes (e.g., Sample ID, Condition, or Batch)."),
          tags$li("Sample IDs should match those in the expression matrix.")
        ),
        h5("Gene Expression Matrix Requirements"),
        tags$ul(
          tags$li("Each row represents a gene (e.g., Gene ID or Gene Symbol)."),
          tags$li("Each column represents a sample; Sample IDs must match metadata."),
          tags$li("Values can be raw read counts (preferred), FPKM, or TPM.")
        )
      ),
      tags$hr(),
      h5("Upload Status and Expression Data Type", style = "font-style: italic;"),
      verbatimTextOutput(ns("upload_status"), placeholder = TRUE)
    )
  )
}
