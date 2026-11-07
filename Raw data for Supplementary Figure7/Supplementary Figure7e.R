library(readxl)
library(ggplot2)
library(reshape2)
library(ggsignif)
library(dplyr)

# 读取Excel文件
file_path <- "E:/0-原始数据_su-2/3-病毒文库构建/5-熵/病毒文库小提琴图.xlsx"
data <- read_excel(file_path)

# 将极小值（小于1e-5）替换为0
data[data < 1e-5] <- 0

# 转换为长格式
data_long <- melt(data, id.vars = "site", variable.name = "Column", value.name = "Value")

# 自定义颜色
custom_colors <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#FF6279", "#6d2947", "#0000FF")

# 绘制小提琴图 + 箱线图 + 显著性标记
p <- ggplot(data_long, aes(x = Column, y = Value, fill = Column)) +
  geom_violin(trim = FALSE, color = "black", width = 2.3) +
  geom_boxplot(width = 0.1, color = "black", fill = "white", outlier.shape = NA) +
  scale_fill_manual(values = custom_colors) +
  scale_y_continuous(limits = c(0, 5)) +  # 保留固定y轴范围
  labs(x = "Column", y = "Entropy") +
  theme_minimal() +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black"),
    axis.ticks = element_line(color = "black"),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    axis.text.x = element_text(size = 12, angle = 30, hjust = 1),
    axis.text.y = element_text(size = 12)
  ) +
  geom_signif(
    comparisons = list(
      c("MutDNA", "Mutplasmid"),
      c("MutDNA", "DMS library"),
      c("DMS library", "WSN/1993 H1"),
      c("DMS library", "Perth/2009 H3")
    ),
    map_signif_level = TRUE,
    y_position = c(4.65, 4.1, 4.1, 4.65)
  )

# 显示图形
print(p)

# 保存图形
ggsave("E:/0-原始数据_su-2/3-病毒文库构建/5-熵/病毒文库小提琴图.png", plot = p, width = 4.5, height = 3, dpi = 300)
ggsave("E:/0-原始数据_su-2/3-病毒文库构建/5-熵/病毒文库小提琴图.pdf", plot = p, width = 4, height = 3)