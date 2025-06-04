# server/mod_step1.R

mod_step1_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    meta_data <- reactiveVal(NULL)
    raw_data <- reactiveVal(NULL)
    expr_type <- reactiveVal(NULL)
    auto_expr_type <- reactiveVal(NULL)

    upload_statuses <- reactiveValues(meta = NULL, raw = NULL)

    guess_expression_type <- function(expr_matrix, sample_n = 2, tolerance = 1e5) {
      if (is.null(expr_matrix)) return(NULL)
      if (ncol(expr_matrix) < sample_n) return("Unknown")

      numeric_values <- unlist(expr_matrix)
      numeric_values <- numeric_values[!is.na(numeric_values)]

      if (all(numeric_values %% 1 == 0, na.rm = TRUE)) return("Counts")

      non_zero_values <- numeric_values[numeric_values != 0]
      non_integer_ratio <- mean(non_zero_values %% 1 != 0)

      max_val <- max(numeric_values)
      min_val <- min(numeric_values)

      if (non_integer_ratio > 0.05 && non_integer_ratio < 0.8 && max_val < 2e4 && min_val >= 0)
        return("Counts")
      if (non_integer_ratio > 0.8 && max_val > 1e4 && min_val >= 0)
        return("FPKM")

      sample_cols <- sample(ncol(expr_matrix), min(sample_n, ncol(expr_matrix)))
      col_sums <- colSums(expr_matrix[, sample_cols, drop = FALSE], na.rm = TRUE)
      if (all(abs(col_sums - 1e6) < tolerance)) return("TPM")

      return("Unknown")
    }

    update_controls <- function() {
      if (!is.null(meta_data()) && !is.null(raw_data()) && expr_type() != "Unknown") {
        updateActionButton(session, "to_step2", disabled = FALSE)
      } else {
        updateActionButton(session, "to_step2", disabled = TRUE)
      }
    }

    observeEvent(input$meta_file, {
      shinyjs::runjs("
        const blocker = document.getElementById('mouse-blocker');
        if (blocker) {
          blocker.style.display = 'block';
          blocker.style.pointerEvents = 'auto';
        }
      ")
      on.exit(shinyjs::runjs("
        const blocker = document.getElementById('mouse-blocker');
        if (blocker) {
          blocker.style.pointerEvents = 'none';
          blocker.style.display = 'none';
        }
      "), add = TRUE)

      df <- load_csv(input$meta_file, label = "Metadata File")
      if (is.null(df)) {
        upload_statuses$meta <- "❌ Metadata upload failed. Please check the file format."
      } else {
        meta_data(df)
        upload_statuses$meta <- "✅ Metadata successfully uploaded."
        update_controls()
      }
    })

    observeEvent(input$raw_data_file, {
      shinyjs::runjs("
        const blocker = document.getElementById('mouse-blocker');
        if (blocker) {
          blocker.style.display = 'block';
          blocker.style.pointerEvents = 'auto';
        }
      ")
      on.exit(shinyjs::runjs("
        const blocker = document.getElementById('mouse-blocker');
        if (blocker) {
          blocker.style.pointerEvents = 'none';
          blocker.style.display = 'none';
        }
      "), add = TRUE)

      df <- load_csv(input$raw_data_file, label = "Expression Matrix")
      if (is.null(df)) {
        upload_statuses$raw <- "❌ Gene expression matrix upload failed. Please check the file format."
      } else {
        numeric_cols <- sapply(df[-1], is.numeric)
        df <- cbind(df[1], df[-1][, numeric_cols, drop = FALSE])
        raw_data(df)

        expr_matrix <- df[, -1, drop = FALSE]

        withProgress(message = "Detecting Expression Data Type...", value = 0.5, {
          auto_mode <- guess_expression_type(expr_matrix)
          incProgress(1)
        })

        auto_expr_type(auto_mode)
        expr_type(auto_mode)

        updateSelectInput(session, "manual_expr_type",
          choices = c("Auto", "TPM", "FPKM", "Counts"),
          selected = "Auto"
        )

        type_msg <- switch(auto_mode,
          "TPM" = "🔍 Detected expression data type: TPM.",
          "Counts" = "🔍 Detected expression data type: Counts.",
          "FPKM" = "🔍 Detected expression data type: FPKM.",
          "Unknown" = "❓ Unable to determine expression data type. Please check your file."
        )

        upload_statuses$raw <- paste(
          "✅ Gene expression matrix successfully uploaded.",
          type_msg,
          sep = "\n"
        )

        update_controls()
      }
    })

    observeEvent(input$manual_expr_type, {
      current_raw <- raw_data()
      if (is.null(current_raw)) return()

      auto_mode <- auto_expr_type()
      if (is.null(auto_mode)) {
        expr_matrix <- current_raw[, -1, drop = FALSE]
        auto_mode <- guess_expression_type(expr_matrix)  # fallback
        auto_expr_type(auto_mode)
      }

      final_mode <- if (input$manual_expr_type != "Auto") input$manual_expr_type else auto_mode
      expr_type(final_mode)

      base_msg <- switch(auto_mode,
        "TPM" = "🔍 Detected expression data type: TPM.",
        "Counts" = "🔍 Detected expression data type: Counts.",
        "FPKM" = "🔍 Detected expression data type: FPKM.",
        "Unknown" = "❓ Unable to determine expression data type. Please check your file."
      )

      override_note <- if (input$manual_expr_type != "Auto" && final_mode != auto_mode) {
        "❗️ Note: User-selected expression type overrides the automatic inference."
      } else {
        NULL
      }

      upload_statuses$raw <- paste(
        "✅ Gene expression matrix successfully uploaded.",
        base_msg,
        override_note,
        sep = "\n"
      )

      update_controls()
    })

    output$upload_status <- renderText({
      status_text <- paste(c(upload_statuses$meta, upload_statuses$raw), collapse = "\n")
      if (status_text == "" || is.null(status_text)) {
        return("💡 No uploads yet. Please upload both metadata and expression matrix.")
      }
      return(status_text)
    })

    return(list(
      meta_data = meta_data,
      raw_data = raw_data,
      expr_type = expr_type
    ))
  })
}
