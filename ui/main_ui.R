# ui/main_ui.R

ui <- fluidPage(
  theme = my_theme,

  tags$head(tags$style(HTML("
    body {
      font-family: '-apple-system', 'BlinkMacSystemFont', 'sans-serif';
      background-color: #F5F5F7;
      color: #1D1D1F;
    }
    h1 { font-weight: bold; color: #1D1D1F; }
    h4 { font-style: italic; color: #6E6E73; }
    .shiny-input-container .form-control {
      height: 38px;
      border-radius: 8px;
      border: 1px solid #D1D1D6;
      box-shadow: none;
      background-color: white;
    }
    .btn-secondary, .btn-primary {
      background: #2C2C2E;
      color: white;
      border: none;
      box-shadow: none;
      border-radius: 8px;
    }
    .btn-secondary:hover, .btn-primary:hover {
      background: #3A3A3C;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    }
    .btn-processing {
      height: 38px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 12px;
      background: linear-gradient(90deg, #0066cc, #005bb5);
      border: none;
      color: white;
      font-weight: 500;
      transition: background 0.3s ease, box-shadow 0.3s ease, transform 0.2s ease;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }
    .btn-processing:hover {
      background: linear-gradient(90deg, #005bb5, #004a99);
      box-shadow: 0 6px 14px rgba(0, 0, 0, 0.2);
      transform: translateY(-2px);
    }
    .btn-plot {
      height: 38px;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 12px;
      background: linear-gradient(90deg, #bb5112, #a4470f);
      border: none;
      color: white;
      font-weight: 500;
      transition: background 0.3s ease, box-shadow 0.3s ease, transform 0.2s ease;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }
    .btn-plot:hover {
      background: linear-gradient(90deg, #a4470f, #8c390d);
      box-shadow: 0 6px 14px rgba(0, 0, 0, 0.2);
      transform: translateY(-2px);
    }
  "))),

  titlePanel(
    div(
      HTML("<h1 style='margin-top: 25px; margin-bottom: 15px; padding-top: 10px;'>&#129504; GLIBO-TxEval</h1>"),
      HTML("<h4 style='text-align: right; margin-top: 0; font-style: italic; font-weight: normal; font-size: 18px; padding-bottom: 10px;'>
      Glioma Brain Organoid Treatment Response Evaluation</h4>")
    )
  ),

  tabsetPanel(
    id = "steps",
    type = "hidden",

    tabPanel("Step 1: Upload Datasets", mod_step1_ui("step1")),
    tabPanel("Step 2: Confirm Sample Matching", mod_step2_ui("step2")),
    tabPanel("Step 3: Select Metadata Filters", mod_step3_ui("step3")),
    tabPanel("Step 4: Apply Filters and Download Data", mod_step4_ui("step4")),
    tabPanel("Step 5: Process Data", mod_step5_ui("step5")),
    tabPanel("Step 6: Visualization", mod_step6_ui("step6"))
  ),

  mod_footer_ui("footer")
)
