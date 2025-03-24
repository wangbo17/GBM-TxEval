mod_step6_server <- function(id, processed_data, colData, extra_info_columns) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    observeEvent(input$start_plotting, {
      req(processed_data(), colData())

      withProgress(message = "Generating Plot", value = 0, {
        incProgress(0.5, detail = "Loading processed results...")

        data <- processed_data()
        data <- na.omit(data)

        col_info <- colData()[, c("Patient_ID", extra_info_columns()), drop = FALSE]
        data <- merge(data, col_info, by = "Patient_ID", all.x = TRUE)

        data$Responder <- factor(
          ifelse(data$NES < 0, "Down Responders", "Up Responders"), 
          levels = c("Up Responders", "Down Responders")
        )

        color_map <- switch(
          input$color_palette,
          "viridis" = c("Up Responders" = "#440154", "Down Responders" = "#21908d"),
          "cividis" = c("Up Responders" = "#00224E", "Down Responders" = "#94D740"),
          "default" = c("Up Responders" = "#1f77b4", "Down Responders" = "#d62728")
        )

        hover_text <- apply(data, 1, function(row) {
          extra_info_text <- paste(
            extra_info_columns(),
            ": ",
            row[extra_info_columns()],
            collapse = "<br>"
          )
          paste(
            "Patient ID:", row["Patient_ID"],
            "<br>PC1 Score:", round(as.numeric(row["PC1_Score"]), 2),
            "<br>NES:", round(as.numeric(row["NES"]), 2),
            if (!is.null(extra_info_text) && extra_info_text != "") paste0("<br>", extra_info_text)
          )
        })

        plotly_plot <- plot_ly(
          data, 
          x = ~PC1_Score, 
          y = ~NES, 
          type = "scatter", 
          mode = "markers", 
          text = hover_text,
          hoverinfo = "text",
          color = ~Responder,
          colors = color_map,
          marker = list(size = input$point_size, opacity = input$point_opacity)
        ) %>%
          layout(
            title = "NES vs PC1",
            xaxis = list(title = "log2FC PC1"),
            yaxis = list(title = "JARID2 NES"),
            hovermode = "closest"
          )

        output$plot_output <- renderPlotly({ plotly_plot })

        incProgress(0.5, detail = "Finalizing visualization...")
      })
    })
  })
}
