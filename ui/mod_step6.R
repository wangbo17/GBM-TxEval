# ui/mod_step6.R

mod_step6_ui <- function(id) {
  ns <- NS(id)

  sidebarLayout(
    sidebarPanel(
      h4("Generate Visualization"),
      br(),

      sliderInput(ns("point_size"), "Point Size:", min = 5, max = 20, value = 12, step = 1),
      sliderInput(ns("point_opacity"), "Point Opacity:", min = 0.1, max = 1, value = 0.8, step = 0.05),

      br(),

      actionButton(ns("start_plotting"), "Generate Plot", class = "btn-plot", style = "width: 45%;"),
      br(),
      fluidRow(
        column(6, actionButton(ns("to_step5"), "Back", class = "btn-secondary"))
      )
    ),
    mainPanel(
      h4("Visualization Output"),
      plotlyOutput(ns("plot_output"), height = "600px")
    )
  )
}