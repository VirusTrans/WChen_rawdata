# 1. 加载必要的包
library(readxl)
library(ggplot2)
library(writexl)

# 2. 读取 Excel 数据
data <- read_excel("E:/19-文章手稿/图片/Figure4/相关性分析/Palate1Lung1.xlsx")

# 3. 删除 "5th Cell" 和 "10th Cell" 同时为 0 的行
filtered_data <- data[!(data$`Palate1` == 0 & data$`Lung1` == 0), ]

# 4. 替换单边为 0 的值为 0.000001（避免 log10(0)）
filtered_data$`Palate1`[filtered_data$`Palate1` == 0] <- 0.000001
filtered_data$`Lung1`[filtered_data$`Lung1` == 0] <- 0.000001

# 5. 添加 log10(%) 转换列
filtered_data$log10_Palate1  <- log10(filtered_data$`Palate1` * 100)
filtered_data$log10_Lung1 <- log10(filtered_data$`Lung1` * 100)

# 6. 计算 Pearson 相关系数
R_value <- cor(filtered_data$log10_Palate1, filtered_data$log10_Lung1, use = "complete.obs")
cat("R:", round(R_value, 3), "\n")

# 7. 绘图
p <- ggplot(filtered_data, aes(x = log10_Palate1, y = log10_Lung1)) +
  geom_jitter(size = 0.1, width = 0.1, height = 0.1, color = "#808080") +
  annotate("text", x = 2, y = 2, label = "Chicken 1#", hjust = 1, vjust = 1, size = 2) +
  annotate("text", x = 2, y = -3.3, 
           label = as.expression(bquote(italic(r) == .(round(R_value, 3)))), 
           hjust = 1, vjust = 1, size = 2) +
  labs(
    x = expression("Freq in Palate1 (log"[10]*"%)"),
    y = expression("Freq in Lung1 (log"[10]*"%)")
  ) +
  scale_x_continuous(limits = c(-4, 2), breaks = seq(-4, 2, 1)) +
  scale_y_continuous(limits = c(-4, 2), breaks = seq(-4, 2, 1)) +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black", size = 0.3),
    axis.ticks = element_line(color = "black", size = 0.3),
    axis.title = element_text(size = 7),
    axis.text = element_text(size = 7, color = "black"),
    legend.position = "none"
  )

# 8. 显示并保存图像为 TIFF
print(p)
# 保存为 TIFF
ggsave("E:/19-文章手稿/图片/Figure4/相关性分析/Palate1Lung1_delete_zero_R.tiff", 
       plot = p, width = 1.3, height = 1.3, dpi = 600, compression = "lzw")

# 保存为 PDF
ggsave("E:/19-文章手稿/图片/Figure4/相关性分析/Palate1Lung1_delete_zero_R.pdf", 
       plot = p, width = 1.3, height = 1.3)

# 9. 导出转换后的数据
write_xlsx(filtered_data, "E:/19-文章手稿/图片/Figure4/相关性分析/Palate1Lung1_delete_zero_R.xlsx")
