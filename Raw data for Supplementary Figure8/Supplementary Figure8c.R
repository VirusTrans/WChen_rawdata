# ===== 1. 加载必要的包 =====
library(readxl)
library(ggplot2)
library(dplyr)
library(tidyr)

# ===== 2. 读取数据 =====
file_path <- "G:/0-数据去除终止密码子桑基图/0-Mice.xlsx"
data <- read_excel(file_path)
colnames(data)[1] <- "Barcode_ID"

# ===== 3. 数据预处理 =====
plot_data <- data %>%
  pivot_longer(
    cols = -Barcode_ID,
    names_to = "Sample",
    values_to = "Value"
  ) %>%
  filter(Value > 0) %>%
  group_by(Sample) %>%
  mutate(Value_norm = Value / sum(Value)) %>%
  arrange(Sample, desc(Value_norm)) %>% 
  mutate(
    RankID = row_number(),
    ColorIndex = as.factor((RankID - 1) %% 5 + 1)
  ) %>%
  ungroup()

# ===== 4. 样本顺序 (Y轴自上而下) =====
sample_order <- c("Mice1", "Mice2", "Mice3")
plot_data$Sample <- factor(plot_data$Sample, levels = rev(sample_order))

# ===== 5. 绘图核心设置 =====
# 换算系数：1pt = 0.3527mm
size_025pt <- 0.25 * 0.3527  # 用于线条粗细

p <- ggplot(plot_data, aes(
  y = Sample,
  x = Value_norm,
  fill = ColorIndex,
  group = desc(RankID)
)) +
  
  # ✅ color = NA 移除描边，是 PDF 渲染成功的关键
  geom_col(
    width = 0.5, 
    color = NA
  ) +
  
  # 颜色循环方案
  scale_fill_manual(
    values = c("1" = "#de9b15", "2" = "#9ecae1", "3" = "#2171b5", "4" = "#159870", "5" = "#08519c"),
    guide = "none"
  ) +
  
  # X 轴设置 (0-100)
  scale_x_continuous(
    expand = c(0, 0),
    limits = c(0, 1.001), 
    breaks = seq(0, 1, 0.2),
    labels = c("0", "20", "40", "60", "80", "100")
  ) +
  
  # Y 轴设置 (消除留白)
  scale_y_discrete(
    expand = expansion(add = c(0.5, 0.5))
  ) +
  
  theme_classic() +
  theme(
    # ✅ 轴线粗细：0.25pt
    axis.line.y = element_line(linewidth = size_025pt, color = "black"),
    axis.line.x = element_line(linewidth = size_025pt, color = "black"),
    
    # ✅ 刻度线：开启 Y 轴刻度，粗细 0.25pt
    axis.ticks.x = element_line(linewidth = size_025pt, color = "black"),
    axis.ticks.y = element_line(linewidth = size_025pt, color = "black"),
    axis.ticks.length = unit(0.8, "mm"),
    
    # ✅ 字体：8磅 (8pt)
    axis.text.x = element_text(color = "black", size = 8),
    axis.text.y = element_text(color = "black", size = 8),
    
    axis.title = element_blank(),
    
    # 控制图形比例，防止出现多余空白
    aspect.ratio = 0.15, 
    plot.margin = margin(t = 2, r = 5, b = 2, l = 2, unit = "mm")
  )

# ===== 6. 导出 PNG =====
ggsave(
  "G:/0-数据去除终止密码子桑基图/Mice.png",
  plot = p,
  width = 240,   # 宽度适中，使 8pt 字体清晰可见
  height = 15,   
  units = "mm",
  dpi = 600
)

# ===== 7. 导出 PDF =====
ggsave(
  "G:/0-数据去除终止密码子桑基图/Mice.pdf",
  plot = p,
  width = 240,
  height = 15,
  units = "mm",
  device = cairo_pdf
)

# ===== 8. 预览 =====
print(p)