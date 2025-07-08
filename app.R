# app.R

library(shiny)
setwd("/mnt/scratch/gdmn373/GBM-TxEval")

# Source global settings and resources
source("global.R")

# Load UI and server definitions
source("ui/main_ui.R")
source("server/main_server.R")

# Launch the Shiny application
options(shiny.launch.browser = TRUE)
shinyApp(ui = ui, server = server)
