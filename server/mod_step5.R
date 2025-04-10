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

    # Final processed donor-level result table
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
          label = "Select normalization method:",
          choices = c("FPKM", "TPM"),
          selected = "FPKM"
        )
      }
    })

    # Render table
    output$processed_results <- renderDT({
      datatable(processed_data(), options = list(scrollX = TRUE))
    })

    # Main logic
    observeEvent(input$start_processing, {
      req(colData(), countData())

      selected_gmt <- if (input$gene_set_choice == "symbol") gmt_data_symbol else gmt_data
      current_type <- expr_type()

      # Step 1: Determine normalization method and apply normalization
      normalized_data <- NULL

      withProgress(message = "Preprocessing Expression Data", value = 0.3, {
        if (current_type %in% c("TPM", "FPKM")) {
          normalized_data <- countData()
        } else {
          method <- input$normalization_method
          normalized_data <- if (method == "TPM") {
            calculate_tpm(countData(), gene_lengths)
          } else {
            calculate_fpkm(countData(), gene_lengths)
          }
        }

        # Step 2: Filter low-expression genes (based on global Q1)
        all_values <- unlist(normalized_data)
        global_q1 <- quantile(all_values[all_values > 0], probs = 0.25, na.rm = TRUE)

        normalized_data <- filter_low_expression_genes(
          countData = normalized_data,
          colData = colData(),
          threshold = global_q1,
          prop_thresh = input$prop_thresh
        )

        # Set PC1 rotation vector
        selected_pc1_data(
          if (current_type == "TPM") pc1_data_tpm else if (current_type == "FPKM") pc1_data_fpkm
          else if (input$normalization_method == "TPM") pc1_data_tpm else pc1_data_fpkm
        )
      })

      # Step 3: Per-donor processing
      donors <- sort(unique(colData()$Donor_ID))
      total_donors <- length(donors)
      results <- data.frame(Donor_ID = character(), Model = character(), PC1_Score = numeric(), ES = numeric())

      withProgress(message = "Processing Donors", value = 0, {
        for (i in seq_along(donors)) {
          donor <- donors[i]
          incProgress(1 / total_donors, detail = paste0("Donor ID: ", donor, " [", i, "/", total_donors, "]"))

          donor_colData <- colData()[colData()$Donor_ID == donor, ]
          sample_ids <- intersect(colnames(normalized_data), donor_colData$Sample_ID)
          donor_expr <- normalized_data[, sample_ids, drop = FALSE]

          log2fc <- calculate_log2fc(donor_colData, donor_expr)
          pc1_scores <- calculate_pc1_scores(log2fc, selected_pc1_data())
          es_scores  <- perform_fgsea(log2fc, selected_gmt)

          pc1 <- if (nrow(pc1_scores) > 0) pc1_scores$PC1_Score else NA
          es  <- if (nrow(es_scores) > 0)  es_scores$ES         else NA
          model <- unique(donor_colData$Model)
          if (length(model) > 1) model <- model[1]

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
