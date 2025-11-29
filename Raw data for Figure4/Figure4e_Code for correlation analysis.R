library(readxl)
library(ggplot2)
library(ggrepel)
library(grid)

# 读取数据
df <- read_excel("G:/21-文章手稿_rawdata-3/Figure4/Raw data for Figure4/Raw data for Figure4.xlsx")

# 计算 Pearson 相关系数
cor_palate <- cor.test(df$Average_Palate_Frequency, df$AUC, method = "pearson")
cor_lung <- cor.test(df$Average_Lung_Frequency, df$AUC, method = "pearson")

r_palate <- round(cor_palate$estimate, 3)
r_lung <- round(cor_lung$estimate, 3)

# 绘图
p <- ggplot() +
  # 腭部点和回归线
  geom_point(data = df, aes(x = Average_Palate_Frequency, y = AUC, color = "Palate"), size = 0.1) +
  geom_smooth(data = df, aes(x = Average_Palate_Frequency, y = AUC, color = "Palate"), method = "lm", se = FALSE, size = 0.3) +
  geom_text_repel(data = df, aes(x = Average_Palate_Frequency, y = AUC, label = Mutant),
                  color = "#E69F00", size = 1, max.overlaps = 10, box.padding = 0.01, point.padding = 0.01) +
  # 肺部点和回归线
  geom_point(data = df, aes(x = Average_Lung_Frequency, y = AUC, color = "Lung"), size = 0.1) +
  geom_smooth(data = df, aes(x = Average_Lung_Frequency, y = AUC, color = "Lung"), method = "lm", se = FALSE, size = 0.3) +
  geom_text_repel(data = df, aes(x = Average_Lung_Frequency, y = AUC, label = Mutant),
                  color = "#009E73", size = 1, max.overlaps = 10, box.padding = 0.01, point.padding = 0.01) +
  
  # 标注 R 值
  annotate("text", x = max(df$Average_Lung_Frequency, df$Average_Palate_Frequency, na.rm = TRUE), y = 1.4,
           label = paste0("Palate R = ", r_palate), color = "#E69F00", size = 1, hjust = 1) +
  annotate("text", x = max(df$Average_Lung_Frequency, df$Average_Palate_Frequency, na.rm = TRUE), y = 1.365,
           label = paste0("Lung R = ", r_lung), color = "#009E73", size = 1, hjust = 1) +
  
  # 设置颜色
  scale_color_manual(values = c("Palate" = "#E69F00", "Lung" = "#009E73")) +
  
  # 坐标轴标签
  labs(x = "Frequency%", y = "Relative AUC(fold change)", color = NULL) +
  
  # 自定义主题和字体大小
  theme_minimal() +
  theme(
    legend.position = "none",
    plot.title = element_blank(),
    axis.text = element_text(size = 7),                # 坐标刻度字体 10磅
    axis.title.x = element_text(size = 7, face = "bold"),  # 横轴标题 12磅
    axis.title.y = element_text(size = 7, face = "bold"),  # 纵轴标题 12磅
    panel.grid = element_blank(),
    axis.line = element_line(color = "black",  size = 0.3),
    axis.ticks.length = unit(5, "pt"),
    axis.ticks.x.top = element_blank(),
    axis.ticks.y.right = element_blank(),
    axis.text.x.top = element_blank(),
    axis.text.y.right = element_blank(),
    axis.ticks.x = element_line(color = "black",  size = 0.3),
    axis.ticks.y = element_line(color = "black",  size = 0.3)
  ) +
  
  # 添加上、右坐标轴线（不显示刻度和标签）
  scale_x_continuous(sec.axis = dup_axis(labels = NULL, name = NULL)) +
  scale_y_continuous(sec.axis = dup_axis(labels = NULL, name = NULL)) +
  
  # 设置Y轴范围
  coord_cartesian(ylim = c(0.8, 1.4)) +
  coord_cartesian(xlim = c(0, 50))
# 显示图形
print(p)

# 保存为 PDF 文件
ggsave("G:/21-文章手稿_rawdata-3/Figure4/Raw data for Figure4/Raw data for Figure4e.pdf",
       plot = p, width = 5.2, height = 6.4, units = "cm", dpi = 300, device = cairo_pdf)
