# server/mod_step2.R

mod_step2_server <- function(id, meta_data_reactive) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    extra_info_columns <- reactiveVal(character())

    output$col_matching_static <- renderUI({
      req(meta_data_reactive())
      cols <- colnames(meta_data_reactive())

      tagList(
        selectInput(ns("sample_id_col"), "Match Sample ID to:", choices = cols),
        selectInput(ns("donor_id_col"), "Match Donor ID to:", choices = cols),
        selectInput(ns("model_col"), "Match Glioma Model to:", choices = cols),
        selectInput(ns("tumor_condition_col"), "Match Condition (Untreated vs. Treated) to:", choices = cols)
      )
    })

    output$meta_preview_step2 <- DT::renderDT({
      req(meta_data_reactive())
      DT::datatable(meta_data_reactive(), options = list(scrollX = TRUE))
    })

    output$extra_info_ui <- renderUI({
      req(meta_data_reactive())
      available_columns <- setdiff(
        colnames(meta_data_reactive()),
        c(input$sample_id_col, input$donor_id_col, input$model_col, input$tumor_condition_col, extra_info_columns())
      )

      tagList(
        selectInput(ns("extra_info_select"), "Add Metadata Column:", choices = available_columns),
        actionButton(ns("add_extra_info"), "Add", class = "btn-success"),
        br(),
        uiOutput(ns("extra_info_list"))
      )
    })

    observeEvent(input$add_extra_info, {
      req(input$extra_info_select)
      new_col <- input$extra_info_select
      current <- extra_info_columns()
      if (!(new_col %in% current)) {
        extra_info_columns(c(current, new_col))
      }
    })

    output$extra_info_list <- renderUI({
      req(extra_info_columns())
      tagList(
        lapply(extra_info_columns(), function(col_name) {
          div(
            class = "d-flex align-items-end mb-2",
            div(style = "flex: 1;", strong(col_name)),
            div(style = "margin-left: 10px;",
                actionButton(ns(paste0("remove_", col_name)), "✖", class = "btn-danger btn-sm"))
          )
        })
      )
    })

    observe({
      lapply(extra_info_columns(), function(col_name) {
        observeEvent(input[[paste0("remove_", col_name)]], {
          extra_info_columns(setdiff(extra_info_columns(), col_name))
        })
      })
    })

    return(list(
      sample_id_col = reactive(input$sample_id_col),
      donor_id_col = reactive(input$donor_id_col),
      model_col = reactive(input$model_col),
      tumor_condition_col = reactive(input$tumor_condition_col),
      extra_info_columns = extra_info_columns
    ))
  })
}
