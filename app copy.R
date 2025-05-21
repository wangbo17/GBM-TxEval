# app.R

library(shiny)
setwd("/resstore/b0135/Users/bowang/GBM-TxEval")

getwd()

ui <- fluidPage(
  titlePanel(
    div(
      HTML("
        <h1 style='display: flex; align-items: center; gap: 5px;'>
          <img src='https://raw.githubusercontent.com/wangbo17/GBM-TxEval/main/www/logo.png' height='120' alt='Logo' />
          GBM-TxEval
        </h1>
      ")
    )
  ),
  
  mainPanel(
    p("测试图片是否正常显示")
  )
)

server <- function(input, output, session) {
  
}

shinyApp(ui, server)