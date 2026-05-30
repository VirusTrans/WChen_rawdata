# =========================
# 1. 加载包
# =========================
library(readxl)
library(ggseqlogo)
library(ggplot2)
library(gridExtra)
library(Biostrings)

# =========================
# 2. 读取数据
# =========================
df <- read_excel("G:/0-投稿/NC/Raw data/Raw data for Supplementary Figure 6.xlsx")

# =========================
# 3. 排序
# =========================
df$site <- as.character(df$site)
df$site_num <- as.numeric(df$site)
df <- df[order(df$site_num), ]

# =========================
# 4. 密码子 → 氨基酸频率
# =========================
codon_cols <- colnames(df)[!colnames(df) %in% c("site", "wildtype", "site_num")]
codon_to_aa <- GENETIC_CODE[codon_cols]
amino_acids <- sort(unique(codon_to_aa))

aa_matrix <- matrix(0, nrow = length(amino_acids), ncol = nrow(df))
rownames(aa_matrix) <- amino_acids
colnames(aa_matrix) <- df$site

for (aa in amino_acids) {
  relevant_codons <- names(codon_to_aa[codon_to_aa == aa])
  if (length(relevant_codons) > 1) {
    aa_matrix[aa, ] <- rowSums(df[, relevant_codons, drop = FALSE])
  } else {
    aa_matrix[aa, ] <- unlist(df[, relevant_codons])
  }
}

# 去掉终止密码子
aa_matrix <- aa_matrix[rownames(aa_matrix) != "*", ]

# =========================
# ⭐ 5. 去掉首尾位点
# =========================
valid_idx <- 2:(nrow(df) - 1)
aa_matrix <- aa_matrix[, valid_idx]
df <- df[valid_idx, ]

# =========================
# ⭐ 6. 统一Y轴刻度
# =========================
y_max <- max(aa_matrix, na.rm = TRUE)

# （如果是频率数据，也可以直接用 1）
# y_max <- 1

# =========================
# 7. 颜色方案
# =========================
custom_colors <- make_col_scheme(
  chars = c('A','C','D','E','F','G','H','I','K','L','M','N','P','Q','R','S','T','V','W','Y'),
  cols  = c(
    '#E41A1C','#377EB8','#4DAF4A','#984EA3','#FF7F00',
    '#FDB462','#A65628','#F781BF','#FB8072','#80B1D3',
    '#B3DE69','#FCCDE5','#D9D9D9','#BC80BD','#CCEBC5',
    '#FFED6F','#1F78B4','#33A02C','#FB9A99','#E31A1C'
  )
)

# =========================
# 8. 分段绘图
# =========================
site_ids <- colnames(aa_matrix)
wt_aa <- as.character(GENETIC_CODE[df$wildtype])

cols_per_row <- 80
total_cols <- ncol(aa_matrix)
rows <- ceiling(total_cols / cols_per_row)
plot_list <- list()

for (i in seq_len(rows)) {
  
  start_idx <- (i - 1) * cols_per_row + 1
  end_idx <- min(i * cols_per_row, total_cols)
  
  pfm_sub <- aa_matrix[, start_idx:end_idx, drop = FALSE]
  sub_sites <- site_ids[start_idx:end_idx]
  sub_wt <- wt_aa[start_idx:end_idx]
  
  n_sites <- ncol(pfm_sub)
  
  # 每10个位点显示标签
  sub_sites_num <- as.numeric(sub_sites)
  display_labels <- ifelse(sub_sites_num %% 10 == 0 & sub_sites_num != 561, sub_sites, "")
  
  p <- ggseqlogo(pfm_sub, method = "custom", seq_type = "aa", col_scheme = custom_colors) +
    scale_x_continuous(
      breaks = 1:n_sites,
      labels = display_labels,
      expand = c(0.005, 0.005),
      sec.axis = dup_axis(labels = sub_wt, name = NULL)
    ) +
    scale_y_continuous(
      limits = c(0, 0.017),
      expand = c(0, 0)
    ) +
    theme_logo() +
    theme(
      aspect.ratio = 0.06,
      plot.margin = margin(t = 2, r = 5, b = 2, l = 5, unit = "pt"),
      axis.text.x.bottom = element_text(size = 6, color = "grey20"),
      axis.text.x.top = element_text(size = 6, face = "bold", color = "#084594"),
      axis.title.y = element_text(size = 7),
      axis.ticks.length = unit(2, "pt"),
      legend.position = "none",
      panel.background = element_blank()
    ) +
    labs(x = NULL, y = "Freq")
  
  plot_list[[i]] <- p
}

# =========================
# 9. 导出 PDF
# =========================
if (length(plot_list) > 0) {
  
  output_file <- "G:/0-投稿/NC/Raw data/Full_Library_Bright_Version.pdf"
  
  pdf(output_file, width = 18, height = 1.3 * length(plot_list))
  do.call(grid.arrange, c(plot_list, ncol = 1))
  dev.off()
  
  message("绘图完成（统一Y轴 + 去首尾位点）！文件路径：", output_file)
}