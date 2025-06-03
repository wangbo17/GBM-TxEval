pc1_rotation <- readRDS("/resstore/b0135/Users/bowang/GBM-TxEval/data/pc1_rotation_original_tpm.rds")

gencode_v27 <- read.csv("/resstore/b0135/Users/bowang/GBM-TxEval/data/gencode_v27.csv", sep = ",", stringsAsFactors = FALSE, header = FALSE)

colnames(gencode_v27) <- c("ID", "Length", "Symbol")
gencode_v27$ID <- trimws(gencode_v27$ID)
gencode_v27$Symbol <- trimws(gencode_v27$Symbol)

id_to_symbol <- setNames(gencode_v27$Symbol, gencode_v27$ID)

new_names <- id_to_symbol[names(pc1_rotation)]

valid_idx <- !is.na(new_names)
pc1_rotation_symbol <- pc1_rotation[valid_idx]
names(pc1_rotation_symbol) <- new_names[valid_idx]

saveRDS(pc1_rotation_symbol, "/resstore/b0135/Users/bowang/GBM-TxEval/data/pc1_rotation_symbol_tpm.rds")



pc1_rotation <- readRDS("/resstore/b0135/Users/bowang/GBM-TxEval/data/pc1_rotation_original_fpkm.rds")

gencode_v27 <- read.csv("/resstore/b0135/Users/bowang/GBM-TxEval/data/gencode_v27.csv", sep = ",", stringsAsFactors = FALSE, header = FALSE)

colnames(gencode_v27) <- c("ID", "Length", "Symbol")
gencode_v27$ID <- trimws(gencode_v27$ID)
gencode_v27$Symbol <- trimws(gencode_v27$Symbol)

id_to_symbol <- setNames(gencode_v27$Symbol, gencode_v27$ID)

new_names <- id_to_symbol[names(pc1_rotation)]

valid_idx <- !is.na(new_names)
pc1_rotation_symbol <- pc1_rotation[valid_idx]
names(pc1_rotation_symbol) <- new_names[valid_idx]

saveRDS(pc1_rotation_symbol, "/resstore/b0135/Users/bowang/GBM-TxEval/data/pc1_rotation_symbol_fpkm.rds")

