mod_step5_server <- function(
  id,
  colData,
  countData,
  extra_info_columns,
  gene_lengths,
  pc1_data,
  gmt_data,
  gmt_data_symbol
) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    processed_data <- reactiveVal(data.frame(Patient_ID = character(), PC1_Score = numeric(), NES = numeric()))

    output$processed_results <- renderDT({
      datatable(processed_data(), options = list(scrollX = TRUE))
    })

    observeEvent(input$start_processing, {
      req(colData(), countData())

      selected_gmt <- if (input$gene_set_choice == "symbol") gmt_data_symbol else gmt_data
      patients <- unique(colData()$Patient_ID)
      total_patients <- length(patients)
      results <- data.frame(Patient_ID = character(), PC1_Score = numeric(), NES = numeric())

      withProgress(message = "Processing Patients", value = 0, {
        for (i in seq_along(patients)) {
          patient <- patients[i]
          incProgress(1 / total_patients, detail = paste0("ID: ", patient, " [", i, "/", total_patients, "]"))

          patient_colData <- colData()[colData()$Patient_ID == patient, ]
          sample_ids <- intersect(colnames(countData()), patient_colData$Sample_ID)
          patient_counts <- countData()[, sample_ids, drop = FALSE]

          if (input$skip_fpkm) {
            fpkm <- patient_counts
          } else {
            fpkm <- calculate_fpkm(patient_counts, gene_lengths)
          }

          log2fc <- calculate_log2fc(patient_colData, fpkm)
          pc1_scores <- calculate_pc1_scores(log2fc, pc1_data)
          nes_scores <- perform_fgsea(log2fc, selected_gmt)

          pc1 <- ifelse(nrow(pc1_scores) > 0, pc1_scores$PC1_Score, NA)
          nes <- ifelse(nrow(nes_scores) > 0, nes_scores$NES, NA)

          results <- rbind(results, data.frame(Patient_ID = patient, PC1_Score = pc1, NES = nes))
        }
        updateActionButton(session, "start_plotting", disabled = FALSE)
      })

      processed_data(results)

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
