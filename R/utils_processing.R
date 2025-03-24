# R/utils_processing.R

# Function to calculate FPKM values
calculate_fpkm <- function(countData, gene_lengths) {
  matched_gene_lengths <- gene_lengths[match(rownames(countData), gene_lengths$ID), ]
  gene_lengths_kb <- matched_gene_lengths$Length / 1000
  total_counts <- colSums(countData)
  fpkm_values <- sweep(countData, 1, gene_lengths_kb, FUN = "/")
  fpkm_values <- sweep(fpkm_values, 2, total_counts / 1e6, FUN = "/")
  return(fpkm_values)
}

# Function to calculate log2 fold change (log2FC)
calculate_log2fc <- function(colData, fpkm_countData) {
  log2fc_results <- data.frame()
  unique_patients <- unique(colData$Patient_ID)
  for (patient in unique_patients) {
    patient_samples <- colData[colData$Patient_ID == patient, ]
    primary_sample <- patient_samples$Sample_ID[patient_samples$Tumor_Stage == "Primary"]
    recurrent_sample <- patient_samples$Sample_ID[patient_samples$Tumor_Stage == "Recurrent"]
    primary_expr <- fpkm_countData[, primary_sample]
    recurrent_expr <- fpkm_countData[, recurrent_sample]
    log2fc <- log2((recurrent_expr + 0.01) / (primary_expr + 0.01))
    log2fc_df <- data.frame(Gene = rownames(fpkm_countData), Log2FC = log2fc)
    log2fc_df$Patient_ID <- patient
    rownames(log2fc_df) <- NULL
    log2fc_results <- rbind(log2fc_results, log2fc_df)
  }
  return(split(log2fc_results, log2fc_results$Patient_ID))
}

# Function to calculate PC1 score
calculate_pc1_scores <- function(log2fc_list, pc1_data) {
  pc1_scores <- lapply(log2fc_list, function(patient_data) {
    common_genes <- intersect(names(pc1_data), patient_data$Gene)
    patient_data <- patient_data[patient_data$Gene %in% common_genes, ]
    patient_data <- patient_data[match(common_genes, patient_data$Gene), ]
    pc1_values <- pc1_data[common_genes] * patient_data$Log2FC
    pc1_score <- sum(pc1_values, na.rm = TRUE)
    data.frame(Patient = unique(patient_data$Patient), PC1_Score = pc1_score)
  })
  pc1_score_df <- do.call(rbind, pc1_scores)
  return(pc1_score_df)
}

# Function to perform FGSEA analysis
perform_fgsea <- function(log2fc_list, gmt_data) {
  set.seed(17)
  nes_results <- data.frame(Patient = character(), NES = numeric(), stringsAsFactors = FALSE)
  for (patient in names(log2fc_list)) {
    res <- log2fc_list[[patient]]
    ranks <- res$Log2FC
    names(ranks) <- res$Gene
    ranks <- ranks + runif(length(ranks), min = -1e-7, max = 1e-7)
    ranks <- sort(ranks, decreasing = TRUE)
    fgsea_res <- fgseaMultilevel(pathways = gmt_data, stats = ranks, eps = 1e-10, minSize = 15, maxSize = 50000, nPermSimple = 10000)
    nes <- if (nrow(fgsea_res) > 0) fgsea_res$NES[1] else NA
    nes_results <- rbind(nes_results, data.frame(Patient = patient, NES = nes))
  }
  return(nes_results)
}
