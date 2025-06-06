# R/utils_processing.R

# Function to calculate FPKM values
calculate_fpkm <- function(countData, gene_lengths, gene_label_type) {
  gene_ids <- rownames(countData)

  gene_column <- if (gene_label_type == "Symbol") "Symbol" else "ID"

  idx <- match(gene_ids, gene_lengths[[gene_column]])

  matched_gene_lengths <- gene_lengths[idx, ]
  gene_lengths_kb <- matched_gene_lengths$Length / 1000

  total_counts <- colSums(countData)
  fpkm_values <- sweep(countData, 1, gene_lengths_kb, FUN = "/")
  fpkm_values <- sweep(fpkm_values, 2, total_counts / 1e6, FUN = "/")
  
  return(fpkm_values)
}

# Function to calculate TPM values
calculate_tpm <- function(countData, gene_lengths, gene_label_type) {
  gene_ids <- rownames(countData)

  gene_column <- if (gene_label_type == "Symbol") "Symbol" else "ID"

  idx <- match(gene_ids, gene_lengths[[gene_column]])

  matched_gene_lengths <- gene_lengths[idx, ]
  gene_lengths_kb <- matched_gene_lengths$Length / 1000

  rpk <- sweep(countData, 1, gene_lengths_kb, FUN = "/")
  scaling_factors <- colSums(rpk, na.rm = TRUE) / 1e6
  tpm <- sweep(rpk, 2, scaling_factors, FUN = "/")
  
  return(tpm)
}

# Function to normalize condition labels
normalize_condition <- function(cond) {
  cond_lower <- tolower(cond)
  ifelse(cond_lower %in% c("untreated", "primary", "0"), "Untreated",
         ifelse(cond_lower %in% c("treated", "recurrent", "1"), "Treated", cond))
}

# Function to filter low-expression genes (fixed)
filter_low_expression_genes <- function(countData, colData, threshold, prop_thresh) {
  colData$Condition <- normalize_condition(colData$Condition)

  untreated_samples <- colData$Sample_ID[colData$Condition == "Untreated"]
  treated_samples   <- colData$Sample_ID[colData$Condition == "Treated"]

  selected_genes <- rownames(countData)[apply(countData, 1, function(gene_expr) {
    expr_untreated <- gene_expr[untreated_samples]
    expr_treated   <- gene_expr[treated_samples]

    prop_untreated <- sum(expr_untreated >= threshold, na.rm = TRUE) / sum(!is.na(expr_untreated))
    prop_treated   <- sum(expr_treated   >= threshold, na.rm = TRUE) / sum(!is.na(expr_treated))

    return(prop_untreated >= prop_thresh || prop_treated >= prop_thresh)
  })]

  filtered <- countData[selected_genes, , drop = FALSE]
  message("Low-expression gene filtering complete. Retained genes: ", nrow(filtered))
  return(filtered)
}

# Function to calculate log2 fold change (log2FC)
calculate_log2fc <- function(colData, expr_matrix) {
  colData$Condition <- normalize_condition(colData$Condition)
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
