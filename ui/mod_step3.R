# ui/mod_step3.R

mod_step3_ui <- function(id) {
  ns <- NS(id)

  sidebarLayout(
    sidebarPanel(
      h4("Define Filtering Criteria"),

      h5("Optional: Add Extra Filtering Criteria"),
      uiOutput(ns("extra_filter_ui")),
      br(),

      uiOutput(ns("extra_filter_list")),
      br(),

      fluidRow(
        column(6, actionButton(ns("to_step2"), "Back", class = "btn-secondary")),
        column(6, actionButton(ns("to_step4"), "Next", class = "btn-primary"))
      )
    ),
    mainPanel(
      h4("Metadata Preview"),
      DT::DTOutput(ns("meta_preview_step3"))
    )
  )
}
