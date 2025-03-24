mod_step6_ui <- function(id) {
  ns <- NS(id)
  
  sidebarLayout(
    sidebarPanel(
      h4("Generate Visualization"),
      br(),
      
      sliderInput(ns("point_size"), "Marker Size:", min = 5, max = 20, value = 12.5, step = 0.5),
      sliderInput(ns("point_opacity"), "Marker Opacity:", min = 0.1, max = 1, value = 0.75, step = 0.05),
      selectInput(ns("color_palette"), "Color Palette:", 
                  choices = list("Default" = "default", 
                                 "Viridis" = "viridis", 
                                 "Cividis" = "cividis"), 
                  selected = "default"),
      br(),

      actionButton(ns("start_plotting"), "Generate Plot", class = "btn-plot", style = "width: 45%;"),
      br(),
      fluidRow(
        column(6, actionButton(ns("to_step5"), "Back", class = "btn-secondary"))
      )
    ),
    mainPanel(
      h4("Visualization Output"),
      plotlyOutput(ns("plot_output"))
    )
  )
}
