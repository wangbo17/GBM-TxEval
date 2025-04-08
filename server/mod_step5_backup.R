# server/mod_step5.R

mod_step5_server <- function(
  id,
  colData,
  countData,
  extra_info_columns,
  gene_lengths,
  expr_type,
  gmt_data,
  gmt_data_symbol,
  pc1_data_fpkm,
  pc1_data_tpm
) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    processed_data <- reactiveVal(
      data.frame(Donor_ID = character(), Model = character(), PC1_Score = numeric(), ES = numeric())
    )
    selected_pc1_data <- reactiveVal(NULL)

    # Render normalization method UI
    output$norm_ui <- renderUI({
      current_type <- expr_type()
      if (current_type %in% c("TPM", "FPKM")) {
        tagList(
          p("Detected Expression Type:", strong(current_type)),
          p(em("Normalization method is fixed based on expression input."))
        )
      } else {
        radioButtons(
          ns("normalization_method"),
          label = "Select Normalization Method:",
          choices = c("FPKM", "TPM"),
          selected = "FPKM"
        )
      }
    })

    # Render result table
    output$processed_results <- renderDT({
      datatable(processed_data(), options = list(scrollX = TRUE))
    })

    # Main processing
    observeEvent(input$start_processing, {
      req(colData(), countData())

      selected_gmt <- if (input$gene_set_choice == "symbol") gmt_data_symbol else gmt_data
      donors <- sort(unique(colData()$Donor_ID))
      total_donors <- length(donors)
      results <- data.frame(Donor_ID = character(), Model = character(), PC1_Score = numeric(), ES = numeric())

      # Set PC1 data
      current_type <- expr_type()
      if (current_type == "TPM") {
        selected_pc1_data(pc1_data_tpm)
      } else if (current_type == "FPKM") {
        selected_pc1_data(pc1_data_fpkm)
      } else {
        method <- input$normalization_method
        selected_pc1_data(if (method == "TPM") pc1_data_tpm else pc1_data_fpkm)
      }

      withProgress(message = "Processing", value = 0, {
        for (i in seq_along(donors)) {
          donor <- donors[i]
          incProgress(1 / total_donors, detail = paste0("Donor ID: ", donor, " [", i, "/", total_donors, "]"))

          donor_colData <- colData()[colData()$Donor_ID == donor, ]
          sample_ids <- intersect(colnames(countData()), donor_colData$Sample_ID)
          donor_counts <- countData()[, sample_ids, drop = FALSE]

          # Determine expression matrix
          expr_matrix <- if (current_type %in% c("TPM", "FPKM")) {
            donor_counts
          } else {
            method <- input$normalization_method
            if (method == "TPM") {
              calculate_tpm(donor_counts, gene_lengths)
            } else {
              calculate_fpkm(donor_counts, gene_lengths)
            }
          }

          # Calculate scores
          log2fc <- calculate_log2fc(donor_colData, expr_matrix)
          pc1_scores <- calculate_pc1_scores(log2fc, selected_pc1_data())
          es_scores  <- perform_fgsea(log2fc, selected_gmt)

          pc1 <- if (nrow(pc1_scores) > 0) pc1_scores$PC1_Score else NA
          es  <- if (nrow(es_scores) > 0)  es_scores$ES         else NA

          # Extract model (ensure uniqueness)
          model <- unique(donor_colData$Model)
          if (length(model) > 1) model <- model[1]

          # Append row
          results <- rbind(results, data.frame(
            Donor_ID = donor,
            Model = model,
            PC1_Score = pc1,
            ES = es,
            stringsAsFactors = FALSE
          ))
        }

        updateActionButton(session, "start_plotting", disabled = FALSE)
      })

      processed_data(results)

      # UI: download button
      output$download_results_ui <- renderUI({
        req(nrow(processed_data()) > 0)
        downloadButton(ns("download_results"), "Download Results", class = "btn-success")
      })

      output$download_results <- downloadHandler(
        filename = function() "results.csv",
        content = function(file) {
          write.csv(processed_data(), file, row.names = FALSE)
        }
      )

      updateActionButton(session, "to_step6", disabled = FALSE)
    })

    return(list(
      processed_data = processed_data
    ))
  })
}
