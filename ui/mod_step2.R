# ui/mod_step2.R

mod_step2_ui <- function(id) {
  ns <- NS(id)

  sidebarLayout(
    sidebarPanel(
      h4("Confirm Sample Matching"),
      uiOutput(ns("col_matching_static")),
      br(),

      h5("Optional: Add Extra Information"),
      uiOutput(ns("extra_info_ui")),
      br(),

      fluidRow(
        column(6, actionButton(ns("to_step1"), "Back", class = "btn-secondary")),
        column(6, actionButton(ns("to_step3"), "Next", class = "btn-primary"))
      )
    ),
    mainPanel(
      h4("Metadata Preview"),
      DT::DTOutput(ns("meta_preview_step2"))
    )
  )
}
