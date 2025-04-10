# global.R

# ==== Load Required Libraries ====
# shiny
if (!requireNamespace("shiny", quietly = TRUE)) {
  install.packages("shiny", dependencies = TRUE)
}
library(shiny)

# bslib
if (!requireNamespace("bslib", quietly = TRUE)) {
  install.packages("bslib", dependencies = TRUE)
}
library(bslib)

# DT
if (!requireNamespace("DT", quietly = TRUE)) {
  install.packages("DT", dependencies = TRUE)
}
library(DT)

# data.table
if (!requireNamespace("data.table", quietly = TRUE)) {
  install.packages("data.table", dependencies = TRUE)
}
library(data.table)

# fgsea (Bioconductor package)
if (!requireNamespace("fgsea", quietly = TRUE)) {
  if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
  }
  BiocManager::install("fgsea")
}
library(fgsea)

# plotly
if (!requireNamespace("plotly", quietly = TRUE)) {
  install.packages("plotly", dependencies = TRUE)
}
library(plotly)

# ==== Global Options ====
options(shiny.maxRequestSize = 500 * 1024^2)

# ==== Load Reference Data ====
gene_lengths <- read.csv("data/gencode_v27.csv")
pc1_data_tpm <- readRDS("data/pc1_rotation_original_tpm.rds")
pc1_data_fpkm <- readRDS("data/pc1_rotation_original_fpkm.rds")
gmt_data <- list(JARID2 = readLines("data/GTRD_TFs_GeneIDs_JARID2_v2019.txt"))
gmt_data_symbol <- list(JARID2 = readLines("data/GTRD_TFs_GeneNames_JARID2_v2019.txt"))

# ==== Load Custom Functions ====
source("R/utils_io.R")
source("R/utils_processing.R")

# ==== Define Global UI Theme ====
source("R/utils_theme.R")
my_theme <- get_gltx_theme()


# ==== Load UI Modules ====
source("ui/mod_footer_ui.R")
source("ui/mod_step1.R")
source("ui/mod_step2.R")
source("ui/mod_step3.R")
source("ui/mod_step4.R")
source("ui/mod_step5.R")
source("ui/mod_step6.R")

# ==== Load Server Modules ====
source("server/mod_footer_server.R")
source("server/mod_step1.R")
source("server/mod_step2.R")
source("server/mod_step3.R")
source("server/mod_step4.R")
source("server/mod_step5.R")
source("server/mod_step6.R")
