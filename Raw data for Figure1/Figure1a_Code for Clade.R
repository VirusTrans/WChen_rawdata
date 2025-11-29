library(ggstream)
library(readxl)
library(dplyr)
library(ggplot2)

# 文件路径和输出目录
file_path <- "C:/Users/chenw/Desktop/序列分析/2-分支流行率图/H9N2.xlsx"
save_dir <- "C:/Users/chenw/Desktop/序列分析/2-分支流行率图/"
x_labels <- c("1966-1996","2000","2004","2008","2012","2016","2020","2024")

# 读取数据并处理
data <- read_excel(file_path) %>%
  mutate(
    Year = as.numeric(Year),
    Year_group = case_when(
      Year >= 1966 & Year <= 1996 ~ "1966-1996",
      TRUE ~ as.character(Year)
    ),
    Clade_group = ifelse(`clade I order`=="B4" & !is.na(`clade II order`), `clade II order`, `clade I order`),
    Main_clade = substr(Clade_group,1,1)
  ) %>%
  filter(!is.na(Year_group), !is.na(Clade_group))

# 汇总每年每个谱系数量
year_clade_count <- data %>%
  group_by(Year_group, Clade_group, Main_clade) %>%
  summarise(Count=n(), .groups="drop") %>%
  arrange(factor(Main_clade, levels=c("Y","G","B")), Clade_group) %>%
  mutate(
    Clade_group = factor(Clade_group, levels=unique(Clade_group)),
    Main_clade = factor(Main_clade, levels=c("Y","G","B"))
  )

# 设置颜色和需要高亮的谱系
legend_colors <- c("Y"="#FFD92F","G"="#9081A7","B"="#E958A1")
highlight <- c("B4.7","G5","Y8")

# 绘制流线图
g <- ggplot(year_clade_count, aes(x=Year_group, y=Count, fill=Main_clade, group=Clade_group)) +
  geom_stream(color="grey30", size=0.1, extra_span=0.15) +
  scale_fill_manual(values=legend_colors, breaks=c("Y","G","B"), labels=c("Y","G","B")) +
  scale_x_discrete(breaks=x_labels) +
  theme_minimal(base_size=10) +
  theme(
    panel.grid=element_blank(),
    axis.line.x=element_line(color="black", size=0.2),
    axis.text.x=element_text(angle=45,hjust=1,color="black"),
    axis.text.y=element_blank(),
    axis.ticks.x=element_line(color="black", size=0.2),
    axis.ticks.y=element_blank(),
    axis.title.y=element_blank(),
    axis.title.x=element_text(color="black"),
    legend.position="none",   # 🚨 隐藏图例
    axis.ticks.length = unit(0.1, "cm")
  ) +
  labs(x="Year", y=NULL)


# 2017年高亮谱系标注
labels_data <- year_clade_count %>% 
  filter(Year_group=="2017", Clade_group %in% highlight) %>%
  arrange(desc(Main_clade)) %>%
  mutate(ypos=cumsum(Count)-Count/2)

g <- g + geom_text(data=labels_data, aes(x="2017", y=ypos, label=Clade_group), size=10/ggplot2::.pt, vjust=0.5, hjust=-0.1, fontface="bold", color="black")

# 左上角比例支架
# 左上角比例支架 (500 sequences)
# 左上角比例标尺 (500 sequences)
y_max <- max(year_clade_count$Count)

g <- g +
  geom_segment(aes(x=-0.2, xend=-0.2, y=y_max-500, yend=y_max),
               inherit.aes=FALSE, color="black", size=0.5) +
  annotate("text", x=-0.15, y=y_max-250, label="500 sequences",
           hjust=0, vjust=0.5, color="black", size=10/ggplot2::.pt)



# 显示图形并保存
print(g)
ggsave(paste0(save_dir,"Clade分组变化.pdf"), plot=g, width=7, height=5, units="cm", dpi=300)
ggsave(paste0(save_dir,"Clade分组变化.tiff"), plot=g, width=7, height=5, units="cm", dpi=300, compression="lzw")
