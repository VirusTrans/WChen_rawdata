# 加载包
library(readxl)
library(ggvenn)

# 设置工作目录
setwd("E:/19-文章手稿/图片/Figure3/Venn图")

# 读取数据
data <- read_excel("Naive1.xlsx")

# 检查列名
required_cols <- c("Virus", "1dpi DI", "3dpi DI", "2dpi CI", "4dpi CI")
if (!all(required_cols %in% names(data))) {
  stop("Excel 文件中缺少必要列，请检查列名是否完全一致。")
}

# 提取每组中非零的 Virus
set1 <- na.omit(data$Virus[data$`1dpi DI` > 0])
set2 <- na.omit(data$Virus[data$`3dpi DI` > 0])
set3 <- na.omit(data$Virus[data$`2dpi CI` > 0])
set4 <- na.omit(data$Virus[data$`4dpi CI` > 0])

# 创建集合列表
venn_list <- list(
  `1dpi DI` = set1,
  `3dpi DI` = set2,
  `2dpi CI` = set3,
  `4dpi CI` = set4
)

# 指定每组颜色
my_colors <- c("#E69F00", "#56B4E9", "#009E73", "#CC79A7")

# 绘制 4重 Venn 图
venn_plot <- ggvenn(
  venn_list,
  fill_color = my_colors,   # 每个组一个颜色
  fill_alpha = 0.5,
  stroke_color = "black",
  stroke_size = 0.1,        # 线条宽度 0.5 磅
  show_percentage = FALSE,  # 仅显示数量
  set_name_size = 2,
  text_size = 1.5
)

# 保存为 PDF（矢量图）
ggsave(
  filename = "E:/19-文章手稿/图片/Figure3/Venn图/Naive1.pdf",
  plot = venn_plot,
  width = 1.2,
  height = 1.5,
  units = "in",   # 单位英寸
  device = cairo_pdf  # 使用 cairo_pdf 确保高质量矢量输出
)
