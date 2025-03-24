# ui/mod_step1_ui.R

mod_step1_ui <- function(id) {
  ns <- NS(id)

  sidebarLayout(
    sidebarPanel(
      h4("Upload Datasets"),
      fileInput(ns("meta_file"), "Upload Sample Metadata (CSV)", accept = ".csv"),
      fileInput(ns("raw_data_file"), "Upload Gene Expression Matrix (CSV, Max 2GB)", accept = ".csv"),
      actionButton(ns("to_step2"), "Next", class = "btn-primary", disabled = TRUE)
    ),
    mainPanel(
      h4("Instructions"),
      p("Please upload both the metadata and raw gene expression matrix before proceeding."),
      h5("Sample Metadata Requirements"),
      p("The metadata file should be a CSV file where:"),
      tags$ul(
        tags$li("Each row represents a sample."),
        tags$li("Each column contains sample attributes such as Sample ID, Condition, or Batch."),
        tags$li("The metadata file includes unique Sample IDs either as a column or as row names.")
      ),
      h5("Gene Expression Matrix Requirements"),
      p("The gene expression matrix should be a CSV file where:"),
      tags$ul(
        tags$li("Each row represents a gene, which can be identified by either Gene ID or Gene Symbol."),
        tags$li("Each column represents a sample, and Sample IDs must match those in the metadata."),
        tags$li("Values should be either raw read counts (recommended) or FPKM values."),
        tags$li(HTML("If using FPKM values, please select <b>'Exclude FPKM'</b> to avoid redundant normalization."))
      ),
      verbatimTextOutput(ns("upload_status"))
    )
  )
}
