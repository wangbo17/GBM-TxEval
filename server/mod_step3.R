# server/mod_step3.R

mod_step3_server <- function(id, meta_data_reactive) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    extra_filter_columns <- reactiveVal(character())

    output$extra_filter_ui <- renderUI({
      req(meta_data_reactive())
      available_columns <- setdiff(colnames(meta_data_reactive()), extra_filter_columns())

      tagList(
        selectInput(
          ns("extra_filter_select"),
          label = "Add Filtering Column:",
          choices = available_columns,
          selected = NULL
        ),
        actionButton(ns("add_extra_filter"), "Add", class = "btn-success")
      )
    })

    output$extra_filter_list <- renderUI({
      req(extra_filter_columns())
      tagList(
        lapply(extra_filter_columns(), function(col_name) {
          div(
            class = "d-flex align-items-end mb-2",
            div(style = "flex: 1;", strong(col_name)),
            div(style = "margin-left: 10px;",
                actionButton(ns(paste0("remove_filter_", col_name)), "✖", class = "btn-danger btn-sm"))
          )
        })
      )
    })

    observeEvent(input$add_extra_filter, {
      req(input$extra_filter_select)
      new_column <- input$extra_filter_select
      current <- extra_filter_columns()
      if (!(new_column %in% current)) {
        extra_filter_columns(c(current, new_column))
      }
    })

    observeEvent(extra_filter_columns(), {
      lapply(extra_filter_columns(), function(col_name) {
        observeEvent(input[[paste0("remove_filter_", col_name)]], {
          extra_filter_columns(setdiff(extra_filter_columns(), col_name))
        }, ignoreInit = TRUE, ignoreNULL = TRUE)
      })
    })

    output$meta_preview_step3 <- renderDT({
      req(meta_data_reactive())
      datatable(meta_data_reactive(), options = list(scrollX = TRUE))
    })

    observeEvent(input$to_step4, {
      updateTabsetPanel(session = session, inputId = "steps", selected = "Step 4: Apply Filters and Download Data")
    })

    return(list(
      extra_filter_columns = extra_filter_columns,
      selected_filters = extra_filter_columns
    ))
  })
}
