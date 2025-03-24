# server/mod_step3.R

mod_step3_server <- function(id, meta_data_reactive) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    selected_filters <- reactiveVal(character())

    extra_filter_columns <- reactiveVal(character())

    output$col_matching_filter <- renderUI({
      req(meta_data_reactive())
      select_columns <- colnames(meta_data_reactive())
      tagList(
        p("The algorithm relies on Local Recurrence, Radiotherapy and TMZ treatment, and IDH wild-type status."),
        lapply(c("Recurrence Pattern", "Adjuvant Therapy", "IDH Mutation Status"), function(name) {
          selectInput(ns(name), paste("Match", name, "to:"), choices = select_columns,
                      selected = ifelse(length(select_columns) > 0, select_columns[1], NULL))
        })
      )
    })

    output$meta_preview_step3 <- renderDT({
      req(meta_data_reactive())
      datatable(meta_data_reactive(), options = list(scrollX = TRUE))
    })

    output$extra_filter_ui <- renderUI({
      req(meta_data_reactive())
      available_columns <- setdiff(colnames(meta_data_reactive()),
                                   c("Recurrence Pattern", "Adjuvant Therapy", "IDH Mutation Status", extra_filter_columns()))
      tagList(
        selectInput(ns("extra_filter_select"), "Add Extra Filtering Column:", choices = available_columns, selected = NULL),
        actionButton(ns("add_extra_filter"), "Add", class = "btn-success"),
        br(),
        uiOutput(ns("extra_filter_list"))
      )
    })

    observeEvent(input$add_extra_filter, {
      req(input$extra_filter_select)
      new_column <- input$extra_filter_select
      current_cols <- extra_filter_columns()
      if (!(new_column %in% current_cols)) {
        extra_filter_columns(c(current_cols, new_column))
      }
    })

    output$extra_filter_list <- renderUI({
      req(extra_filter_columns())
      tagList(
        lapply(extra_filter_columns(), function(col_name) {
          fluidRow(
            column(10, strong(col_name)),
            column(2, actionButton(ns(paste0("remove_filter_", col_name)), "✖", class = "btn-danger btn-sm"))
          )
        })
      )
    })

    observe({
      for (col_name in extra_filter_columns()) {
        observeEvent(input[[paste0("remove_filter_", col_name)]], {
          extra_filter_columns(setdiff(extra_filter_columns(), col_name))
        })
      }
    })

    observeEvent(input$to_step4, {
      selected_cols <- sapply(c("Recurrence Pattern", "Adjuvant Therapy", "IDH Mutation Status"),
                              function(name) input[[name]], USE.NAMES = FALSE)
      matched_cols <- selected_cols[selected_cols %in% colnames(meta_data_reactive())]
      selected_filters(matched_cols)

      updateTabsetPanel(session = session, inputId = "steps", selected = "Step 4: Apply Filters and Download Data")
    })

    return(list(
      selected_filters = selected_filters,
      extra_filter_columns = extra_filter_columns
    ))
  })
}
