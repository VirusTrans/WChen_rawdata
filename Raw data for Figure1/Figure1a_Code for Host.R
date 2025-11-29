library(ggstream)
library(readxl)
library(dplyr)
library(ggplot2)

# 文件路径和输出目录
file_path <- "C:/Users/chenw/Desktop/序列分析/2-分支流行率图/H9N2.xlsx"
save_dir <- "C:/Users/chenw/Desktop/序列分析/2-分支流行率图/"

# X 轴标签和年份
x_labels <- c("1966-1996","2000","2004","2008","2012","2016","2020","2024")

# 读取数据并处理年份
data <- read_excel(file_path) %>%
  mutate(
    Year = as.numeric(Year),
    Year_group = case_when(
      Year >= 1966 & Year <= 1996 ~ "1966-1996",
      TRUE ~ as.character(Year)
    )
  ) %>%
  filter(!is.na(Year_group), !is.na(`Host classification`))

# 分类宿主
data <- data %>%
  mutate(Host_group = case_when(
    `Host classification` %in% c("Chicken", "Duck", "Avian", "Pigeon", "Goose", "Quail", "Ostrich") ~ "Domestic birds",
    `Host classification` %in% c("Sparrow", "Pheasant", "Wild bird") ~ "Wild birds",
    TRUE ~ "Other"
  ))

# 汇总每年每类宿主数量
year_host_count <- data %>%
  group_by(Year_group, Host_group) %>%
  summarise(Count = n(), .groups = "drop")

# 因子化年份（保证顺序与 Clade 图一致）
year_host_count$Year_group <- factor(
  year_host_count$Year_group,
  levels = c("1966-1996", sort(unique(as.numeric(year_host_count$Year_group[year_host_count$Year_group != "1966-1996"]))))
)

# 流线堆叠顺序
year_host_count$Host_group <- factor(
  year_host_count$Host_group,
  levels = c("Wild birds", "Domestic birds", "Other")
)

# 颜色设置
host_colors <- c(
  "Domestic birds" = "#145AFF",
  "Wild birds"    = "#996633",
  "Other"         = "#9BBB59"
)

# 绘制流线图
g <- ggplot(year_host_count, aes(x = Year_group, y = Count, fill = Host_group, group = Host_group)) +
  geom_stream(color = "grey30", size = 0.1, extra_span = 0.2) +
  scale_fill_manual(values = host_colors,
                    breaks = c("Wild birds","Domestic birds","Other")) +
  scale_x_discrete(breaks = x_labels) +
  theme_minimal(base_size = 10) +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1, color = "black"),
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    axis.ticks.x = element_line(color="black", size=0.2), # X 轴刻度线
    axis.ticks.length = unit(0.1, "cm"),                 # 刻度长度
    axis.title.y = element_blank(),
    axis.title.x = element_text(color = "black"),
    axis.line.x = element_line(color="black", size = 0.2), # X 轴底线
    legend.text = element_text(color = "black"),
    legend.title = element_text(color = "black")
  )


# 左上角比例尺（500 sequences）
y_max <- max(year_host_count$Count)

g <- g +
  geom_segment(aes(x=-0.2, xend=-0.2, y=y_max-500, yend=y_max), inherit.aes=FALSE, color="black", size=0.5) +
  geom_segment(aes(x=-0.2, xend=0, y=y_max, yend=y_max), inherit.aes=FALSE, color="black", size=0.5) +
  geom_segment(aes(x=-0.2, xend=0, y=y_max-500, yend=y_max-500), inherit.aes=FALSE, color="black", size=0.5) +
  annotate("text", x=0.05, y=y_max-250, label="500 sequences", hjust=0, vjust=0.5, color="black", size=10/ggplot2::.pt)

# 显示图形
print(g)

# 保存文件
ggsave(paste0(save_dir,"Host_group变化.pdf"), plot = g, width = 9, height = 4.5, units = "cm", dpi = 300)
ggsave(paste0(save_dir,"Host_group变化.tiff"), plot = g, width = 9, height = 4.5, units = "cm", dpi = 300, compression = "lzw")
