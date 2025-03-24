mod_footer_ui <- function(id) {
  ns <- NS(id)
  
  div(
    style = "position: fixed; bottom: 0; width: 100%; background-color: #F5F5F5; 
             display: flex; justify-content: space-between; align-items: center; 
             padding: 5px 15px; font-size: 14px; height: 22.5px; z-index: 1000; font-family: inherit; border-top: 1px solid #D1D1D6;",
    
    # Left
    div("© University of Leeds 2025", style = "flex: 1; text-align: left; margin-left: 10%;"),
    
    # Center
    div(
      style = "flex: 1; text-align: center;",
      actionLink(ns("privacy_modal"), "Privacy Statement", style = "color: #0066cc; text-decoration: none;")
    ),
    
    # Right
    div(
      style = "flex: 1; text-align: right; margin-right: 10%;",
      actionLink(ns("terms_modal"), "Non-Commercial Terms of Use", style = "color: #0066cc; text-decoration: none;")
    )
  )
}
