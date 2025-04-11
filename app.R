# app.R

library(shiny)
setwd("/resstore/b0135/Users/bowang/GBM-TxEval")

# Source global settings and resources
source("global.R")

# Load UI and server definitions
source("ui/main_ui.R")
source("server/main_server.R")

# Launch the Shiny application
shinyApp(ui = ui, server = server)
