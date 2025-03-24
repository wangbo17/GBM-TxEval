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
        selectInput(ns("patient_id_col"), "Match Patient ID to:", choices = cols),
        selectInput(ns("tumor_stage_col"), "Match Tumor Stage (Primary vs. Recurrent) to:", choices = cols)
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
        c(input$sample_id_col, input$patient_id_col, input$tumor_stage_col, extra_info_columns())
      )

      tagList(
        selectInput(ns("extra_info_select"), "Add Extra Information Column:", choices = available_columns),
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
          fluidRow(
            column(10, strong(col_name)),
            column(2, actionButton(ns(paste0("remove_", col_name)), "✖", class = "btn-danger btn-sm"))
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
      patient_id_col = reactive(input$patient_id_col),
      tumor_stage_col = reactive(input$tumor_stage_col),
      extra_info_columns = extra_info_columns
    ))
  })
}
