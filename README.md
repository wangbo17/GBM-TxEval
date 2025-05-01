# GBM-TxEval: Glioblastoma Treatment Response Evaluation

**Author:** Bo Wang  
**Institution:** University of Leeds  
**Version:** Beta  

## Overview
GBM-TxEval is a computational tool designed to evaluate transcriptional treatment responses in glioblastoma (GBM). It processes longitudinal gene expression data to calculate therapy-induced log2 fold changes, performs gene set enrichment analysis, and projects the results into principal component space. This enables stratification of samples into "Up" and "Down" responder subtypes, supporting the investigation of resistance mechanisms and selection of optimal models for preclinical drug evaluation.

## Workflow Steps

1. **Upload Datasets**  
   Upload the sample metadata and gene expression matrix. The app attempts to auto-detect the expression data type.

2. **Confirm Sample Matching**  
   Match key metadata columns (e.g., Sample ID, Donor ID, Model, Condition) and optionally add extra columns for downstream visualization.

3. **Select Metadata Filters**  
   Define optional filtering criteria (e.g., exclude specific models or conditions) by selecting metadata columns of interest.

4. **Apply Filters and Download Data**  
   Review the filtered dataset and optionally download the metadata and expression matrix for external use.

5. **Process Data**  
   Perform gene set enrichment analysis (GSEA) and PC1 score projection using filtered, normalized expression data. Supports both Ensembl ID and gene symbol-based gene sets.

6. **Visualization**  
   Generate interactive scatter plots of PC1 scores versus JARID2 enrichment scores (ES), with donor-level annotations and metadata tooltips.

## Input Requirements

- **Metadata File (CSV):**
  - Each row represents a sample.
  - Required columns: Sample ID, Donor ID, Condition (e.g., Treated/Untreated), Model.
  - Optional columns: Additional metadata for filtering and plotting.

- **Gene Expression Matrix (CSV):**
  - Rows: Genes (Ensembl IDs or gene symbols).
  - Columns: Sample IDs that match the metadata.
  - Values: Counts, TPM, or FPKM.

## Output

- Filtered metadata and expression matrix  
- PC1 projection scores and GSEA enrichment scores  
- Donor-level responder classification (“Up” or “Down”)  
- Downloadable results table  
- Interactive plots (via Plotly)
