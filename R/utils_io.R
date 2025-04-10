# R/utils_io.R

# General CSV Loading Function
    load_csv <- function(file_input, label = "Data File") {
      req(file_input)
      withProgress(message = paste("Loading", label, "..."), value = 0.5, {
        df <- tryCatch(
          fread(file_input$datapath, header = TRUE, data.table = FALSE, check.names = FALSE),
          error = function(e) NULL
        )
        if (is.null(df)) return(NULL)
        incProgress(1, detail = "Done")
        return(df)
      })
    }