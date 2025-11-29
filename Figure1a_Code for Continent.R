library(ggstream)
library(readxl)
library(dplyr)
library(ggplot2)

# 读取数据
data <- read_excel("C:/Users/chenw/Desktop/序列分析/2-分支流行率图/H9N2.xlsx")

# 年份处理
data <- data %>%
  mutate(
    Year = as.numeric(Year),
    Year_group = case_when(
      Year >= 1966 & Year <= 1996 ~ "1966-1996",
      TRUE ~ as.character(Year)
    )
  ) %>%
  filter(!is.na(Year_group), !is.na(Country))

# 国家映射到大洲
asia <- c("Vietnam","Laos","Cambodia","China","Malaysia","Kazakhstan",
          "Hong Kong","Myanmar","Japan","Tajikistan","Russia","South Korea",
          "Indonesia","Pakistan","Sri Lanka","Bangladesh","India","Nepal",
          "Iran","Afghanistan","Mongolia","Singapore","Israel","Jordan","Lebanon",
          "Oman","United Arab Emirates","Saudi Arabia","Qatar","Kuwait","Iraq")
europe <- c("Italy","Poland","Netherlands","Germany","Czech Republic",
            "Finland","Belgium","UK","Ukraine","Portugal","Norway","Switzerland",
            "Austria","France","Sweden","Ireland","Georgia","Hungary","Russia")
africa <- c("Egypt","Ghana","Togo","Nigeria","Benin","Mali","Senegal",
            "Morocco","Algeria","Uganda","Kenya","Libya","South Africa","Mozambique",
            "Madagascar","Zambia")
america <- c("USA","Canada","Argentina","Chile")
oceania <- c("Australia","Papua New Guinea")
antarctica <- c("Antarctica")

data <- data %>%
  mutate(Continent = case_when(
    Country %in% asia ~ "Asia",
    Country %in% europe ~ "Europe",
    Country %in% africa ~ "Africa",
    Country %in% america ~ "America",
    Country %in% oceania ~ "Oceania",
    Country %in% antarctica ~ "Antarctica",
    TRUE ~ "Other"
  ))

# 汇总每年每大洲数量
year_continent_count <- data %>%
  group_by(Year_group, Continent) %>%
  summarise(Count = n(), .groups = "drop") %>%
  filter(Continent != "Other")

# 因子化年份
year_continent_count$Year_group <- factor(
  year_continent_count$Year_group,
  levels = c("1966-1996", sort(unique(as.numeric(year_continent_count$Year_group[year_continent_count$Year_group != "1966-1996"]))))
)

# 流线堆叠顺序
year_continent_count$Continent <- factor(
  year_continent_count$Continent,
  levels = c("Europe","Antarctica","Oceania","America","Africa","Asia")
)

# 分配颜色
continent_colors <- c(
  "Europe"     = "#56B4E9",
  "Antarctica" = "#999999",
  "Oceania"    = "#D55E00",
  "America"    = "#F0E442",
  "Africa"     = "#009E73",
  "Asia"       = "#E69F00"
)

# 指定 X 轴显示年份
x_ticks <- c("1966-1996", "2000", "2004", "2008", "2012", "2016", "2020", "2024")

# 绘图
g <- ggplot(year_continent_count, aes(x = Year_group, y = Count, fill = Continent, group = Continent)) +
  geom_stream(color = "grey30", size = 0.1, extra_span = 0.2) +
  scale_fill_manual(values = continent_colors,
                    breaks = c("Europe","Antarctica","Oceania","America","Africa","Asia")) +
  scale_x_discrete(breaks = x_ticks) +
  theme_minimal(base_size = 10) +
  theme(
    panel.grid = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1, color = "black"),
    axis.text.y = element_blank(),           # 去掉 Y 轴文本
    axis.ticks.y = element_blank(),          # 去掉 Y 轴刻度
    axis.title.y = element_blank(),          # 去掉 Y 轴标题
    axis.ticks.x = element_line(color="black", size=0.2), # X 轴刻度线
    axis.ticks.length = unit(0.1, "cm"),     # X 轴刻度长度
    axis.line.x = element_line(color="black", size=0.2),  # X 轴底线
    axis.title.x = element_text(color = "black"),
    legend.text = element_text(color = "black"),
    legend.title = element_text(color = "black")
  ) +
  labs(x = "Year", y = NULL, fill = "Continent")

# 左上角比例尺（500 sequences）
y_max <- max(year_continent_count$Count)

g <- g +
  geom_segment(aes(x=-0.2, xend=-0.2, y=y_max-500, yend=y_max), inherit.aes=FALSE, color="black", size=0.5) +
  geom_segment(aes(x=-0.2, xend=0, y=y_max, yend=y_max), inherit.aes=FALSE, color="black", size=0.5) +
  geom_segment(aes(x=-0.2, xend=0, y=y_max-500, yend=y_max-500), inherit.aes=FALSE, color="black", size=0.5) +
  annotate("text", x=0.05, y=y_max-250, label="500 sequences", hjust=0, vjust=0.5, color="black", size=10/ggplot2::.pt)

# 显示图形
print(g)

# 保存
ggsave("C:/Users/chenw/Desktop/序列分析/2-分支流行率图/Continent变化.pdf",
       plot = g, width = 9, height = 4.5, units = "cm", dpi = 300)

ggsave("C:/Users/chenw/Desktop/序列分析/2-分支流行率图/Continent变化.tiff",
       plot = g, width = 9, height = 4.5, units = "cm", dpi = 300, compression = "lzw")
