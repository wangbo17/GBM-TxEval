# server/mod_step5.R

mod_step5_server <- function(
    id,
    colData,
    countData,
    gene_lengths,
    expr_type,
    gmt_data,
    gmt_data_symbol,
    pc1_data_fpkm,
    pc1_data_symbol_fpkm,
    pc1_data_tpm,
    pc1_data_symbol_tpm) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    processed_data <- reactiveVal({
      base_cols <- c("Donor_ID", "Model", "PC1_Score", "ES", "Responder")
      df <- as.data.frame(matrix(ncol = length(base_cols), nrow = 0))
      colnames(df) <- base_cols
      df
    })

    selected_pc1_data <- reactiveVal(NULL)

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

    advanced_mode <- reactiveVal(FALSE)

    observeEvent(input$toggle_advanced, {
      current <- advanced_mode()
      advanced_mode(!current)
      updateActionButton(
        session, "toggle_advanced",
        label = ifelse(!current, "Switch to Default Filtering (Recommended)", "Switch to Advanced Filtering (Experienced Users Only)")
      )
    })

    output$filtering_ui <- renderUI({
      current_type <- expr_type()
      if (is.null(current_type)) {
        return(NULL)
      }

      if (!advanced_mode()) {
        default_threshold <- switch(current_type,
          "TPM" = 0.1,
          "FPKM" = 1,
          "Counts" = 10,
          1
        )

        wellPanel(
          style = "padding: 15px 10px 10px 10px; margin-bottom: 5px;",
          h5("Low Expression Filter"),
          p(em("Expression values below the threshold will be set to zero to filter lowly expressed genes.")),
          selectInput(
            ns("default_thresh_mode"),
            label = paste0("Threshold for ", current_type, ":"),
            choices = switch(current_type,
              "TPM" = c("0.1 (low)" = "0.1", "0.5 (moderate)" = "0.5", "1.0 (strict)" = "1.0", "Custom" = "custom"),
              "FPKM" = c("0.5 (low)" = "0.5", "1.0 (moderate)" = "1.0", "2.0 (strict)" = "2.0", "Custom" = "custom"),
              "Counts" = c("10 (low)" = "10", "20 (moderate)" = "20", "50 (strict)" = "50", "Custom" = "custom"),
              c("1.0" = "1.0", "Custom" = "custom")
            ),
            selected = as.character(default_threshold)
          ),
          conditionalPanel(
            condition = sprintf("input['%s'] == 'custom'", ns("default_thresh_mode")),
            numericInput(
              ns("default_thresh_custom"),
              label = "Custom threshold",
              value = default_threshold,
              min = 0,
              step = 0.1
            )
          )
        )
      } else {
        wellPanel(
          style = "padding: 15px 10px 10px 10px; margin-bottom: 5px;",
          h5("Advanced Filtering"),
          p(em("Retain genes expressed above the 25th percentile (Q1) in at least the specified proportion of 'Untreated' or 'Treated' samples.")),
          sliderInput(
            ns("prop_thresh"),
            label = "Minimum Sample Proportion for Q1 Expression:",
            min = 0,
            max = 1,
            value = 1,
            step = 0.05
          )
        )
      }
    })

    output$processed_results <- renderDT({
      datatable(processed_data(), options = list(scrollX = TRUE))
    })

    observeEvent(input$start_processing, {
      req(colData(), countData())

      selected_gmt <- if (input$gene_set_choice == "symbol") gmt_data_symbol else gmt_data
      current_type <- expr_type()
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

        if (!advanced_mode()) {
          threshold <- if (input$default_thresh_mode == "custom") {
            req(input$default_thresh_custom)
            input$default_thresh_custom
          } else {
            as.numeric(input$default_thresh_mode)
          }

          if (current_type %in% c("TPM", "FPKM")) {
            normalized_data[normalized_data < threshold] <- 0
            message("Applied default filtering on normalized data: values < ", threshold, " set to 0.")
          } else {
            # Counts: filter first, then normalize
            raw_counts <- countData()
            raw_counts[raw_counts < threshold] <- 0
            message("Applied default filtering before normalization: raw counts < ", threshold, " set to 0.")

            method <- input$normalization_method
            normalized_data <- if (method == "TPM") {
              calculate_tpm(raw_counts, gene_lengths)
            } else {
              calculate_fpkm(raw_counts, gene_lengths)
            }
          }
        } else {
          all_values <- unlist(normalized_data)
          global_q1 <- quantile(all_values[all_values > 0], probs = 0.25, na.rm = TRUE)

          normalized_data <- filter_low_expression_genes(
            countData = normalized_data,
            colData = colData(),
            threshold = global_q1,
            prop_thresh = input$prop_thresh
          )
        }

        selected_pc1_data(
          if (current_type %in% c("TPM", "FPKM")) {
            if (input$gene_set_choice == "symbol") {
              if (current_type == "TPM") pc1_data_symbol_tpm else pc1_data_symbol_fpkm
            } else {
              if (current_type == "TPM") pc1_data_tpm else pc1_data_fpkm
            }
          } else {
            method <- input$normalization_method
            if (input$gene_set_choice == "symbol") {
              if (method == "TPM") pc1_data_symbol_tpm else pc1_data_symbol_fpkm
            } else {
              if (method == "TPM") pc1_data_tpm else pc1_data_fpkm
            }
          }
        )
      })

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
          es_scores <- perform_fgsea(log2fc, selected_gmt)

          pc1 <- if (nrow(pc1_scores) > 0) pc1_scores$PC1_Score else NA
          es <- if (nrow(es_scores) > 0) es_scores$ES else NA
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
      })

      results$Responder <- ifelse(results$ES >= 0, "Up", "Down")

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
