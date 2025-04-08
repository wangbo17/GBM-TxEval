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

# Function to calculate TPM values
calculate_tpm <- function(countData, gene_lengths) {
  matched_gene_lengths <- gene_lengths[match(rownames(countData), gene_lengths$ID), ]
  gene_lengths_kb <- matched_gene_lengths$Length / 1000
  rpk <- sweep(countData, 1, gene_lengths_kb, FUN = "/")
  tpm <- sweep(rpk, 2, colSums(rpk) / 1e6, FUN = "/")
  return(tpm)
}

# Function to calculate log2 fold change (log2FC)
calculate_log2fc <- function(colData, expr_matrix) {
  log2fc_results <- data.frame()
  unique_donors <- unique(colData$Donor_ID)
  for (donor in unique_donors) {
    donor_samples <- colData[colData$Donor_ID == donor, ]
    u_sample <- donor_samples$Sample_ID[donor_samples$Condition == "Untreated"]
    t_sample <- donor_samples$Sample_ID[donor_samples$Condition == "Treated"]
    if (length(u_sample) == 0 || length(t_sample) == 0) next
    u_expr <- expr_matrix[, u_sample]
    t_expr <- expr_matrix[, t_sample]
    log2fc <- log2((t_expr + 0.01) / (u_expr + 0.01))
    log2fc_df <- data.frame(Gene = rownames(expr_matrix), Log2FC = log2fc)
    log2fc_df$Donor_ID <- donor
    rownames(log2fc_df) <- NULL
    log2fc_results <- rbind(log2fc_results, log2fc_df)
  }
  return(split(log2fc_results, log2fc_results$Donor_ID))
}

# Function to calculate PC1 score
calculate_pc1_scores <- function(log2fc_list, pc1_data) {
  pc1_scores <- lapply(names(log2fc_list), function(donor) {
    donor_data <- log2fc_list[[donor]]
    common_genes <- intersect(donor_data$Gene, names(pc1_data))

    if (length(common_genes) == 0) {
      return(data.frame(Donor_ID = donor, PC1_Score = NA))
    }

    donor_data <- donor_data[match(common_genes, donor_data$Gene), ]
    weights <- pc1_data[common_genes]
    values <- donor_data$Log2FC

    pc1_score <- sum(weights * values, na.rm = TRUE)

    data.frame(Donor_ID = donor, PC1_Score = pc1_score)
  })

  do.call(rbind, pc1_scores)
}

# Function to perform FGSEA analysis
perform_fgsea <- function(log2fc_list, gmt_data) {
  set.seed(17)
  es_results <- data.frame(Donor_ID = character(), ES = numeric(), stringsAsFactors = FALSE)
  for (donor in names(log2fc_list)) {
    donor_data <- log2fc_list[[donor]]
    ranks <- donor_data$Log2FC
    names(ranks) <- donor_data$Gene
    ranks <- sort(ranks, decreasing = TRUE)
    fgsea_res <- tryCatch(
      fgseaMultilevel(
        pathways = gmt_data,
        stats = ranks,
        eps = 1e-10,
        minSize = 15,
        maxSize = 50000,
        nPermSimple = 10000
      ),
      error = function(e) NULL
    )
    es <- if (!is.null(fgsea_res) && nrow(fgsea_res) > 0) fgsea_res$ES[1] else NA

    if (!is.null(fgsea_res) && nrow(fgsea_res) > 0) {
      message("Donor: ", donor,
              " | Top Pathway: ", fgsea_res$pathway[1],
              " | ES: ", round(fgsea_res$ES[1], 3),
              " | NES: ", round(fgsea_res$NES[1], 3),
              " | padj: ", signif(fgsea_res$padj[1], 3))
    } else {
      message("Donor: ", donor, " | FGSEA failed or returned no result.")
    }


    es_results <- rbind(es_results, data.frame(Donor_ID = donor, ES = es))
  }
  return(es_results)
}
