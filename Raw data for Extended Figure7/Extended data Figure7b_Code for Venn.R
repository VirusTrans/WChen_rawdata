# 加载包
library(ggvenn)
library(readxl)

# 设置工作目录
setwd("E:/0-原始数据_su-2/3-病毒文库构建/3-病毒文库Venn图")


# 读取数据
data <- read_excel("DMS文库Venn图.xlsx")

# 识别每列中的非零值，并移除NA值
set1 <- na.omit(data$Virus[data$MutDNA > 0])
set2 <- na.omit(data$Virus[data$Mutplasmid > 0])
set3 <- na.omit(data$Virus[data$DMS_library > 0])

# 创建一个包含集合的列表
venn_list <- list(MutDNA = set1, Mutplasmid = set2, DMS_library = set3)

# 创建 Venn 图并赋值
venn_plot <- ggvenn(venn_list,
                    fill_color = c("#e69f00", "#56b4e9", "#009e73"),
                    stroke_size = 0.5,
                    show_percentage = TRUE,
                    fill_alpha = 0.5,
                    stroke_color = 'black',
                    stroke_alpha = 1,
                    stroke_linetype = 'solid',
                    text_color = 'black',
                    set_name_size = 5,
                    text_size = 3) +

  theme(plot.title = element_text(hjust = 0.5))  # 标题居中

# 保存图像
ggsave("E:/0-原始数据_su-2/3-病毒文库构建/3-病毒文库Venn图/DMS文库Venn图.png", plot = venn_plot, width = 4.5, height = 4, dpi = 300)
# 保存为 PDF
ggsave("E:/0-原始数据_su-2/3-病毒文库构建/3-病毒文库Venn图/DMS文库Venn图.pdf",  plot = venn_plot, width = 4.5, height = 4, dpi = 300)

