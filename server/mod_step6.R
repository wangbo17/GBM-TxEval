# server/mod_step6.R

mod_step6_server <- function(id, processed_data, colData, extra_info_columns) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observeEvent(input$start_plotting, {
      req(processed_data(), colData())

      withProgress(message = "Generating Plot", value = 0, {
        incProgress(0.3, detail = "Preparing data...")

        data <- processed_data()
        data <- na.omit(data)
        data$Model <- factor(data$Model)

        data$Donor_ID <- as.character(data$Donor_ID)
        col_data_df <- colData()
        col_data_df$Donor_ID <- as.character(col_data_df$Donor_ID)

        extra_cols <- extra_info_columns()
        valid_extra_cols <- extra_cols[extra_cols %in% colnames(col_data_df)]
        cat("Valid extra info columns:\n")
        print(valid_extra_cols)

        if (length(valid_extra_cols) > 0) {
          col_info <- unique(col_data_df[, c("Donor_ID", valid_extra_cols), drop = FALSE])
          data <- merge(data, col_info, by = "Donor_ID", all.x = TRUE)
        }

        # Check structure of merged data
        cat("Columns in merged data:\n")
        print(colnames(data))
        cat("First row of merged data:\n")
        print(data[1, , drop = FALSE])

        # Build hover text
        hover_text <- apply(data, 1, function(row) {
          cat("Processing row:\n")
          print(row)

          if (length(valid_extra_cols) > 0) {
            # check if all valid_extra_cols exist in names(row)
            cat("Row names:\n")
            print(names(row))
            cat("Accessing valid_extra_cols in row:\n")
            print(valid_extra_cols)

            extra_info_text <- paste(
              paste0(valid_extra_cols, ": ", row[valid_extra_cols]),
              collapse = "<br>"
            )
            paste0(
              "Donor ID: ", row[["Donor_ID"]],
              "<br>Model: ", row[["Model"]],
              "<br>PC1 Score: ", round(as.numeric(row[["PC1_Score"]]), 2),
              "<br>ES: ", round(as.numeric(row[["ES"]]), 2),
              "<br>", extra_info_text
            )
          } else {
            paste0(
              "Donor ID: ", row[["Donor_ID"]],
              "<br>Model: ", row[["Model"]],
              "<br>PC1 Score: ", round(as.numeric(row[["PC1_Score"]]), 2),
              "<br>ES: ", round(as.numeric(row[["ES"]]), 2)
            )
          }
        })

        incProgress(0.4, detail = "Building plot...")

        plotly_plot <- plot_ly(
          data,
          x = ~PC1_Score,
          y = ~ES,
          type = 'scatter',
          mode = 'markers+text',
          text = ~Donor_ID,
          textposition = "top center",
          textfont = list(size = 10),
          hovertext = hover_text,
          hoverinfo = "text",
          color = ~Model,
          symbol = ~Model,
          symbols = "circle",
          marker = list(size = input$point_size, opacity = input$point_opacity)
        ) %>% layout(
          title = "",
          xaxis = list(title = "log2FC PC1 Score"),
          yaxis = list(title = "JARID2 Enrichment Score (ES)"),
          legend = list(title = list(text = ""))
        )

        output$plot_output <- renderPlotly({ plotly_plot })

        incProgress(0.3, detail = "Done.")
      })
    })
  })
}
