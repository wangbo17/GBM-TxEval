# GBM-TxEval

GBM-TxEval is a computational tool designed to evaluate transcriptional treatment responses in glioblastoma (GBM). It processes longitudinal gene expression data to calculate therapy-induced log2 fold changes, performs gene set enrichment analysis, and projects the results into principal component space. This enables stratification of samples into "Up" and "Down" responder subtypes, supporting the investigation of resistance mechanisms and selection of optimal models for preclinical drug evaluation.

## 📦 File Structure

- `R/utils_io.R`: File loading utilities.
- `R/utils_processing.R`: Core computation functions (normalization, filtering, log2FC, FGSEA).
- `server/`: Modular server logic for each step.
- `ui/`: Modular UI components for each step.
- `app.R`: Main entry point combining all modules into a seamless workflow.

## ⚙️ Workflow Overview

The analysis pipeline is divided into six modular steps:

### Step 1: Upload Datasets

The first step involves uploading two input files in CSV format: **sample metadata** and a **gene expression matrix**. These inputs are essential for downstream processing and must conform to specific format requirements.

#### 📋 Sample Metadata

The metadata file must contain one row per sample and include the following mandatory columns:

- `Sample_ID`: Unique identifier for each sample.
- `Donor_ID`: Identifier linking paired samples (e.g., untreated/treated) from the same donor.
- `Model`: Label indicating the glioma model used.
- `Condition`: Treatment status of the sample.

The `Condition` column supports flexible input formats. It is case-insensitive and can accept the following values:

- `"Untreated"`, `"Primary"`, or `"0"` → interpreted as **Untreated**
- `"Treated"`, `"Recurrent"`, or `"1"` → interpreted as **Treated**

Optional metadata columns can also be included for annotation and filtering purposes in later steps.

#### 📊 Gene Expression Matrix

The expression matrix must be in **CSV format** and meet the following constraints:

- It must include exactly **one non-numeric column**, which is strictly required to be the **first column**. This column represents the gene identifier (e.g., Ensembl ID or HGNC symbol).
- All remaining columns must be numeric and correspond to sample names.
- Sample names (column headers) must match the values in the `Sample_ID` column of the metadata file. Partial overlap is permitted; unmatched samples will be excluded from analysis.

#### 🔎 Automatic Expression Type Detection

Upon upload, the app attempts to infer the type of expression data (Counts, FPKM, or TPM) using the following heuristic, applied to a random subset of two columns:

- If all values are integers, or if the proportion of non-integer values is between 5% and 80%, the **maximum value is below 20,000**, and all values are non-negative, the matrix is classified as **Counts** (this includes both raw and expected counts).
- If over 80% of values are non-integers, the **maximum value exceeds 10,000**, and all values are non-negative, it is classified as **FPKM**.
- If the sum of values in both sampled columns is approximately **1e6** (within a ±1e5 tolerance), it is classified as **TPM**.
- If these conditions are not met, or if fewer than 2 samples are available, the expression type is labeled **Unknown**.

The detected expression type can be overridden manually by the user.

------

### Step 2: Confirm Sample Matching

This step ensures proper alignment between the sample metadata and the expression matrix. The right panel provides a preview of the uploaded metadata, allowing users to **map column names** to their respective roles:

- `Sample_ID`
- `Donor_ID`
- `Model`
- `Condition` (e.g., untreated vs. treated)

Users can also specify any number of **optional metadata columns** (referred to as "extra information"). These columns may include additional contextual details such as sample origin, treatment regimen, or sequencing batch. Selected extra information columns will:

- Be preserved in the filtered metadata file available for download in Step 4.
- Appear in the final visualization as part of the interactive hover text in Step 6.

There is no upper limit to the number of extra columns retained. Including such information is recommended when additional clinical or experimental annotations may aid interpretation.

------

### Step 3: Define Filtering Criteria

This step allows users to define one or more metadata-based **filtering conditions**. Any column in the uploaded metadata can be selected as a filtering variable—common examples include tumor purity, model subtype, treatment timepoint, or sequencing batch.

- **Zero or more filtering variables** may be selected.
- Filtering columns may be categorical or numeric; however, filtering operates via explicit selection of value levels.

This design supports flexible sample selection for downstream analysis while allowing fine-grained control over cohort composition.

------

### Step 4: Apply Filters and Download Data

In this step, users specify which values within each selected filtering column should be retained. Filtering is performed using **checkbox selection**, where each level in a column can be toggled independently.

> 💡 **Tip**: For numeric columns (e.g., purity scores), we recommend **creating binary classification columns** (e.g., `"HighPurity"` = TRUE/FALSE) in advance. This enables efficient selection via checkboxes and avoids the need for custom sliders.

Once filters are applied:

- The updated sample metadata is shown in the right panel for confirmation.
- Both the filtered metadata (`colData.csv`) and matched expression matrix (`countData.csv`) can be downloaded for external use or archival.

------

### Step 5: Process Data

In this step, GBM-TxEval performs core analytical operations including **expression normalization**, **low-expression filtering**, **log2 fold change calculation**, **PC1 score projection**, and **gene set enrichment analysis (GSEA)**.

#### 🔬 Gene Filtering Options

Two gene filtering strategies are supported:

- **Default Filtering** (Recommended):
  - Expression values below a defined threshold are **set to zero**.
  - Users can choose from **preset thresholds** or specify a **custom value**.
  - If the input data type is **Counts**, the filtering is applied **before normalization**.
- **Advanced Filtering**:
  - Retains genes expressed **above the global first quartile (Q1)** in at least a user-defined **minimum proportion** of samples (e.g., 100%, 75%, etc.).
  - Designed for experienced users needing adaptive filtering based on data distribution.

#### 📐 Expression Normalization

The normalization method depends on the input expression type:

- If the uploaded data is **TPM** or **FPKM**, the normalization method is fixed (i.e., no transformation is applied).
- If the input is **Counts**, users can choose to normalize the data using either:
  - **FPKM**: Fragments Per Kilobase of transcript per Million mapped reads
  - **TPM**: Transcripts Per Million

Normalization is performed using uploaded gene length information, and both TPM and FPKM are computed with consistent formulae.

#### 🧬 Gene Identifier Recognition

The application automatically determines whether the gene identifiers in the expression matrix are:

- **Ensembl IDs**, or
- **HGNC Gene Symbols**

The appropriate gene set (GMT file) is then selected based on this classification. This auto-detection is strongly recommended, and the manual override is provided only as a fallback in rare cases of parsing failure.

#### ⚙️ Processing and Feedback

Once the “Start Processing” button is clicked:

- A progress bar appears, tracking analysis progress across donors.
- The current **Donor ID** and processing index are shown in real-time (e.g., “Donor ID: D123 [3/14]”).

#### 📤 Output

Upon completion, a preview of the results is displayed and a CSV download option is provided.

Each row in the output corresponds to a donor, containing the following columns:

- `Donor_ID`: Unique donor identifier
- `Model`: Glioma model associated with the sample pair
- `PC1_Score`: Projection of log2FC vector into the PC1 space
- `ES`: Enrichment Score from FGSEA (for the JARID2 pathway or selected gene set)
- `Responder`: Binary classification of transcriptional response (`Up` if ES ≥ 0; `Down` otherwise)

The resulting dataset serves as input for the final step: interactive visualization and interpretation.

------

### Step 6: Visualization

This final step generates an interactive scatter plot that enables intuitive exploration of transcriptional responses across donors.

#### 📈 Plot Details

Each point in the plot represents a donor and is plotted as:

- **X-axis**: `PC1_Score` — summarizing the global transcriptional shift based on log2 fold changes
- **Y-axis**: `ES` — Enrichment Score from FGSEA for the specified gene set
- **Color and symbol**: Encodes `Model` type

The following result columns are visualized:

- `Donor_ID`
- `Model`
- `PC1_Score`
- `ES`
- `Responder`

#### 🖱️ Interactive Features

- **Hover Tooltips**: Hovering over a point reveals detailed information, including all retained metadata and extra user-specified columns from earlier steps.
- **Customization Options**:
  - `Point Size`: Adjustable via slider
  - `Point Opacity`: Adjustable via slider

These controls allow users to tune the visual clarity based on dataset size and density.

#### 💾 Export Options

The resulting interactive plot can be downloaded for presentation or publication. Users are encouraged to annotate or further customize the exported figure using external tools as needed.

## 🧠 Author & Acknowledgements

**Developer**: Bo Wang
**Affiliation**: University of Leeds