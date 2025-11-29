# 1. 加载必要的包
library(readxl)
library(ggplot2)
library(writexl)

# 2. 读取 Excel 文件
data <- read_excel("E:/8-相关性分析/BJ1613Vax/Palate4Lung4.xlsx")

# 3. 删除 D1CK7 和 D1CK4 同时为 0 的行
filtered_data <- data[!(data$Palate4 == 0 & data$Lung4 == 0), ]

# 4. 替换 0 为极小值并进行 log10(百分比)转换
data_log10 <- filtered_data[, c("Palate4", "Lung4")]
data_log10[data_log10 == 0] <- 0.000001  # 避免 log(0)
data_log10 <- as.data.frame(lapply(data_log10, function(x) log10(x * 100)))
colnames(data_log10) <- c("log10_Palate4", "log10_Lung4")

# 5. 计算 Pearson R 值
R_value <- cor(data_log10$log10_Palate4, data_log10$log10_Lung4, use = "complete.obs")
cat("R:", round(R_value, 3), "\n")

# 6. 绘图（显示 Pearson R）
p <- ggplot(data_log10, aes(x = log10_Palate4, y = log10_Lung4)) +
  geom_jitter(size = 1, width = 0.1, height = 0.1, color = "#808080") +
  annotate("text", x = 2, y = 2,  
           label = "Chicken 4#", 
           hjust = 1, vjust = 1, size = 5.5) +
  annotate("text", x = 2, y = -3.3,  
           label = as.expression(bquote(italic(r) == .(round(R_value, 3)))), 
           hjust = 1, vjust = 1, size = 5.5) +
  labs(x = expression("Freq in swab at 1dpi (log"[10]*"%)"),
       y = expression("Freq in swab at 3 dpi (log"[10]*"%)")) +
  scale_x_continuous(limits = c(-4, 2), breaks = seq(-4, 2, 1)) +
  scale_y_continuous(limits = c(-4, 2), breaks = seq(-4, 2, 1)) +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black"),
    axis.ticks = element_line(color = "black"),
    axis.title = element_text(size = 16),
    axis.text = element_text(size = 16),
    legend.position = "none"
  )

# 7. 显示并保存图形为 TIFF 格式
print(p)
ggsave("E:/8-相关性分析/BJ1613Vax/Palate4-Palate4_R.tiff", 
       plot = p, width = 3.5, height = 3.5, dpi = 600, compression = "lzw")

# 8. 导出转换后的数据
write_xlsx(data_log10, "E:/8-相关性分析/BJ1613Vax/Palate4-Palate4_R.xlsx")