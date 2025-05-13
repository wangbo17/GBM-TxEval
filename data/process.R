# 载入 pc1_rotation
pc1_rotation <- readRDS("/resstore/b0135/Users/bowang/GBM-TxEval/data/pc1_rotation_original_tpm.rds")

# 载入 gencode 映射表
gencode_v27 <- read.csv("/resstore/b0135/Users/bowang/GBM-TxEval/data/gencode_v27.csv", sep = ",", stringsAsFactors = FALSE, header = FALSE)

# 分列：ID, Length, Symbol
colnames(gencode_v27) <- c("ID", "Length", "Symbol")
gencode_v27$ID <- trimws(gencode_v27$ID)  # 去除空格
gencode_v27$Symbol <- trimws(gencode_v27$Symbol)

# 确保 names(pc1_rotation) 与 ID 匹配，进行映射
id_to_symbol <- setNames(gencode_v27$Symbol, gencode_v27$ID)

# 替换名称
new_names <- id_to_symbol[names(pc1_rotation)]

# 去除无法匹配 Symbol 的基因
valid_idx <- !is.na(new_names)
pc1_rotation_symbol <- pc1_rotation[valid_idx]
names(pc1_rotation_symbol) <- new_names[valid_idx]

# 保存为新的 .rds 文件
saveRDS(pc1_rotation_symbol, "/resstore/b0135/Users/bowang/GBM-TxEval/data/pc1_rotation_symbol_tpm.rds")



# 载入 pc1_rotation
pc1_rotation <- readRDS("/resstore/b0135/Users/bowang/GBM-TxEval/data/pc1_rotation_original_fpkm.rds")

# 载入 gencode 映射表
gencode_v27 <- read.csv("/resstore/b0135/Users/bowang/GBM-TxEval/data/gencode_v27.csv", sep = ",", stringsAsFactors = FALSE, header = FALSE)

# 分列：ID, Length, Symbol
colnames(gencode_v27) <- c("ID", "Length", "Symbol")
gencode_v27$ID <- trimws(gencode_v27$ID)  # 去除空格
gencode_v27$Symbol <- trimws(gencode_v27$Symbol)

# 确保 names(pc1_rotation) 与 ID 匹配，进行映射
id_to_symbol <- setNames(gencode_v27$Symbol, gencode_v27$ID)

# 替换名称
new_names <- id_to_symbol[names(pc1_rotation)]

# 去除无法匹配 Symbol 的基因
valid_idx <- !is.na(new_names)
pc1_rotation_symbol <- pc1_rotation[valid_idx]
names(pc1_rotation_symbol) <- new_names[valid_idx]

# 保存为新的 .rds 文件
saveRDS(pc1_rotation_symbol, "/resstore/b0135/Users/bowang/GBM-TxEval/data/pc1_rotation_symbol_fpkm.rds")

