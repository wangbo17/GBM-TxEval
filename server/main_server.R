# server/main_server.R

server <- function(input, output, session) {
  # === Step Navigation ===

  # Step 1 ➝ Step 2
  observeEvent(input[["step1-to_step2"]], {
    updateTabsetPanel(session, "steps", selected = "Step 2: Confirm Sample Matching")
  })
  # Step 2 ➝ Step 1
  observeEvent(input[["step2-to_step1"]], {
    updateTabsetPanel(session, "steps", selected = "Step 1: Upload Datasets")
  })

  # Step 2 ➝ Step 3
  observeEvent(input[["step2-to_step3"]], {
    updateTabsetPanel(session, "steps", selected = "Step 3: Select Metadata Filters")
  })
  # Step 3 ➝ Step 2
  observeEvent(input[["step3-to_step2"]], {
    updateTabsetPanel(session, "steps", selected = "Step 2: Confirm Sample Matching")
  })

  # Step 3 ➝ Step 4
  observeEvent(input[["step3-to_step4"]], {
    updateTabsetPanel(session, "steps", selected = "Step 4: Apply Filters and Download Data")
  })
  # Step 4 ➝ Step 3
  observeEvent(input[["step4-to_step3"]], {
    updateTabsetPanel(session, "steps", selected = "Step 3: Select Metadata Filters")
  })

  # Step 4 ➝ Step 5
  observeEvent(input[["step4-to_step5"]], {
    updateTabsetPanel(session, "steps", selected = "Step 5: Process Data")
  })
  # Step 5 ➝ Step 4
  observeEvent(input[["step5-to_step4"]], {
    updateTabsetPanel(session, "steps", selected = "Step 4: Apply Filters and Download Data")
  })

  # Step 5 ➝ Step 6
  observeEvent(input[["step5-to_step6"]], {
    updateTabsetPanel(session, "steps", selected = "Step 6: Visualization")
  })
  # Step 6 ➝ Step 5
  observeEvent(input[["step6-to_step5"]], {
    updateTabsetPanel(session, "steps", selected = "Step 5: Process Data")
  })

  # === Load Modules ===
  step1_return <- mod_step1_server("step1")
  step2_return <- mod_step2_server("step2", meta_data_reactive = step1_return$meta_data)
  step3_return <- mod_step3_server("step3", meta_data_reactive = step1_return$meta_data)
  step4_return <- mod_step4_server(
    "step4",
    meta_data_reactive = step1_return$meta_data,
    raw_data_reactive = step1_return$raw_data,
    selected_filters = step3_return$selected_filters,
    extra_filter_columns = step3_return$extra_filter_columns,
    extra_info_columns = step2_return$extra_info_columns,
    rename_map = reactive({
      list(
        Sample_ID = input[["step2-sample_id_col"]],
        Donor_ID = input[["step2-donor_id_col"]],
        Condition = input[["step2-tumor_condition_col"]],
        Model = input[["step2-model_col"]]
      )
    }),
    gene_lengths = gene_lengths
    )
  step5_return <- mod_step5_server(
    "step5",
    colData = step4_return$colData,
    countData = step4_return$countData,
    gene_lengths = gene_lengths,
    expr_type = step1_return$expr_type,
    gmt_data = gmt_data,
    gmt_data_symbol = gmt_data_symbol,
    pc1_data_fpkm = pc1_data_fpkm,
    pc1_data_tpm = pc1_data_tpm
  )
  step6_return <- mod_step6_server(
    "step6",
    processed_data = step5_return$processed_data,
    colData = step4_return$colData,
    extra_info_columns = step2_return$extra_info_columns
    )

  mod_footer_server("footer")
}
