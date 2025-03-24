# global.R

# ==== Load Required Libraries ====
library(shiny)
library(bslib)
library(DT)
library(data.table)
library(fgsea)
library(plotly)

# ==== Global Options ====
options(shiny.maxRequestSize = 500 * 1024^2)

# ==== Load Reference Data ====
gene_lengths <- read.csv("data/gencode.csv")
pc1_data <- readRDS("data/pc1_rotation.rds")
gmt_data <- list(JARID2 = readLines("data/GTRD_TFs_GeneIDs_JARID2.txt"))
gmt_data_symbol <- list(JARID2 = readLines("data/GTRD_TFs_GeneNames_JARID2.txt"))

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
