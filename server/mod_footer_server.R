mod_footer_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    observeEvent(input$privacy_modal, {
      showModal(modalDialog(
        title = "Privacy Statement",
        HTML("
          <p>This application respects your privacy. We do not collect, store, or share any personally identifiable information.</p>
          <p>Any data uploaded to this platform is processed locally and remains under the user's control. Users are responsible for ensuring that the uploaded data complies with applicable privacy regulations and institutional guidelines.</p>
          <p>If you have any concerns regarding data security or privacy, please contact the University of Leeds for further information.</p>
        "),
        easyClose = TRUE,
        footer = modalButton("Close")
      ))
    })

    observeEvent(input$terms_modal, {
      showModal(modalDialog(
        title = "Non-Commercial Terms of Use",
        HTML("
          <p>This software is provided for academic and research purposes only.</p>
          <p>Users are not permitted to use this application for commercial gain, including but not limited to selling access, incorporating it into commercial products, or utilizing results for commercial decision-making.</p>
          <p>By using this application, you agree to the following terms:</p>
          <ul>
            <li>The software is provided 'as is' without any warranties, express or implied.</li>
            <li>The University of Leeds is not liable for any direct, indirect, or consequential damages arising from the use of this application.</li>
            <li>Users must acknowledge the University of Leeds in any publications or presentations derived from the results obtained using this tool.</li>
          </ul>
        "),
        easyClose = TRUE,
        footer = modalButton("Close")
      ))
    })
  })
}
