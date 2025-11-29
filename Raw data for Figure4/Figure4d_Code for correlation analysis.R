library(readxl)
library(ggplot2)
library(ggrepel)
library(grid)

# 读取数据
df <- read_excel("E:/0-原始数据_su-2/11-受体结合_裂腭/0-Receptor binging_相关性分析.xlsx")

# 计算 Pearson 相关系数
cor_palate <- cor.test(df$Palate_Frequency, df$AUC, method = "pearson")
cor_lung <- cor.test(df$Lung_Frequency, df$AUC, method = "pearson")

r_palate <- round(cor_palate$estimate, 3)
r_lung <- round(cor_lung$estimate, 3)

# 绘图
p <- ggplot() +
  geom_point(data = df, aes(x = Palate_Frequency, y = AUC, color = "Palate"), size = 1) +
  geom_smooth(data = df, aes(x = Palate_Frequency, y = AUC, color = "Palate"), method = "lm", se = FALSE) +
  geom_text_repel(data = df, aes(x = Palate_Frequency, y = AUC, label = Mutant),
                  color = "#E69F00", size = 2.5, max.overlaps = 10) +
  
  geom_point(data = df, aes(x = Lung_Frequency, y = AUC, color = "Lung"), size = 1) +
  geom_smooth(data = df, aes(x = Lung_Frequency, y = AUC, color = "Lung"), method = "lm", se = FALSE) +
  geom_text_repel(data = df, aes(x = Lung_Frequency, y = AUC, label = Mutant),
                  color = "#009E73", size = 2.5, max.overlaps = 10) +
  
  annotate("text", x = max(df$Lung_Frequency, df$Palate_Frequency, na.rm = TRUE), y = 2.9,
           label = paste0("Palate R = ", r_palate), color = "#E69F00", size = 5.3, hjust = 1) +
  annotate("text", x = max(df$Lung_Frequency, df$Palate_Frequency, na.rm = TRUE), y = 2.7,
           label = paste0("Lung R = ", r_lung), color = "#009E73", size = 5.3, hjust = 1) +
  
  scale_color_manual(values = c("Palate" = "#E69F00", "Lung" = "#009E73")) +
  labs(x = "Frequency%", y = "Relative AUC(fold change)", color = NULL) +
  
  theme_minimal() +
  theme(
    legend.position = "none",
    plot.title = element_blank(),
    axis.text = element_text(size = 10),               # 坐标轴刻度字体 10 磅
    axis.title.x = element_text(size = 12, face = "bold"),  # 横轴标题字体 12 磅
    axis.title.y = element_text(size = 12, face = "bold"),  # 纵轴标题字体 12 磅
    panel.grid = element_blank(),
    axis.line = element_line(color = "black"),
    axis.ticks.length = unit(5, "pt"),
    axis.ticks.x.top = element_blank(),
    axis.ticks.y.right = element_blank(),
    axis.text.x.top = element_blank(),
    axis.text.y.right = element_blank(),
    axis.ticks.x = element_line(color = "black"),
    axis.ticks.y = element_line(color = "black")
  ) +
  
  scale_x_continuous(sec.axis = dup_axis(labels = NULL, name = NULL)) +
  scale_y_continuous(sec.axis = dup_axis(labels = NULL, name = NULL)) +
  coord_cartesian(ylim = c(0, 3))

# 显示图
print(p)

# 保存为 PDF
ggsave("E:/0-原始数据_su-2/11-受体结合_裂腭/Receptor binging.pdf", plot = p,
       width = 6, height = 8, units = "cm", dpi = 300, device = cairo_pdf)
