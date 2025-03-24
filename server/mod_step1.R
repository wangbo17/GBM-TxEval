# server/mod_step1.R

mod_step1_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    meta_data <- reactiveVal(NULL)
    raw_data <- reactiveVal(NULL)

    upload_statuses <- reactiveValues(meta = NULL, raw = NULL)

    load_csv <- function(file_input) {
      req(file_input)
      withProgress(message = paste("Loading", file_input$name, "..."), value = 0.5, {
        df <- tryCatch(
          fread(file_input$datapath, data.table = FALSE, check.names = FALSE),
          error = function(e) NULL
        )
        if (is.null(df)) return(NULL)
        incProgress(1, detail = "Done")
        return(df)
      })
    }

    observeEvent(input$meta_file, {
      df <- load_csv(input$meta_file)
      if (is.null(df)) {
        upload_statuses$meta <- "❌ Metadata upload failed. Please check the file format."
      } else {
        meta_data(df)
        upload_statuses$meta <- "✅ Metadata successfully uploaded."
        if (!is.null(raw_data())) updateActionButton(session, "to_step2", disabled = FALSE)
      }
    })

    observeEvent(input$raw_data_file, {
      df <- load_csv(input$raw_data_file)
      if (is.null(df)) {
        upload_statuses$raw <- "❌ Gene expression matrix upload failed. Please check the file format."
      } else {
        raw_data(df)
        upload_statuses$raw <- "✅ Gene expression matrix successfully uploaded."
        if (!is.null(meta_data())) updateActionButton(session, "to_step2", disabled = FALSE)
      }
    })

    output$upload_status <- renderText({
      paste(c(upload_statuses$meta, upload_statuses$raw), collapse = "\n")
    })

    return(list(
      meta_data = meta_data,
      raw_data = raw_data
    ))
  })
}
