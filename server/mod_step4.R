# server/mod_step4.R

mod_step4_server <- function(
  id,
  meta_data_reactive,
  raw_data_reactive,
  selected_filters,
  extra_filter_columns,
  extra_info_columns,
  rename_map,
  gene_lengths
) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    all_filters <- reactive({
      filters <- selected_filters()
      extras <- extra_filter_columns()
      unique(c(filters, extras))
    })

    colData <- reactive({
      req(meta_data_reactive(), rename_map())
      df <- meta_data_reactive()

      # Apply filters if any
      for (col in all_filters()) {
        input_id <- paste0("filter_", col)
        filter_vals <- input[[input_id]]
        if (!is.null(filter_vals)) {
          df <- df[df[[col]] %in% filter_vals, , drop = FALSE]
        }
      }

      # Rename columns
      renames <- rename_map()
      for (new_name in names(renames)) {
        old_name <- renames[[new_name]]
        if (!is.null(old_name) && old_name %in% colnames(df)) {
          colnames(df)[colnames(df) == old_name] <- new_name
        }
      }

      final_cols <- c("Sample_ID", "Donor_ID", "Condition", "Model", extra_info_columns())
      selected_cols <- final_cols[final_cols %in% colnames(df)]
      df <- df[, selected_cols, drop = FALSE]

      return(df)
    })

    countData <- reactive({
      req(raw_data_reactive(), colData())

      raw_df <- raw_data_reactive()
      rownames(raw_df) <- raw_df[[1]]
      raw_df <- raw_df[, -1, drop = FALSE]

      raw_df <- raw_df[rownames(raw_df) %in% gene_lengths$ID, , drop = FALSE]
      raw_df <- raw_df[rowSums(is.na(raw_df)) == 0, , drop = FALSE]
      raw_df <- raw_df[, colSums(is.na(raw_df)) == 0, drop = FALSE]

      raw_df <- raw_df[, colnames(raw_df) %in% colData()$Sample_ID, drop = FALSE]
      return(raw_df)
    })

    output$filter_options <- renderUI({
      req(meta_data_reactive())
      filters <- all_filters()
      df <- meta_data_reactive()

      if (length(filters) == 0) {
        return(p(em("All samples will be retained (no filters applied).")))
      }

      tagList(
        p(strong("Please select the values to retain for each filter column below.")),
        lapply(filters, function(col) {
          checkboxGroupInput(
            inputId = ns(paste0("filter_", col)),
            label = paste("Filter:", col),
            choices = unique(df[[col]]),
            selected = unique(df[[col]])
          )
        })
      )
    })

    output$filtered_preview <- renderDT({
      datatable(colData(), options = list(scrollX = TRUE))
    })

    output$download_colData <- downloadHandler(
      filename = function() "colData.csv",
      content = function(file) {
        write.csv(colData(), file, row.names = FALSE)
      }
    )

    output$download_countData <- downloadHandler(
      filename = function() "countData.csv",
      content = function(file) {
        write.csv(countData(), file, row.names = TRUE)
      }
    )

    return(list(
      colData = colData,
      countData = countData
    ))
  })
}
