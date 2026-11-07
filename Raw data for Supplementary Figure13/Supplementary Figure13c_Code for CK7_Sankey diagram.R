# ===== 设置工作目录 =====
setwd("G:/1-桑基图_aa")

# ===== 加载包 =====
library(ggplot2)
library(ggalluvial)
library(dplyr)
library(readxl)
library(ggthemes)

# ===== 读取数据 =====
data <- read_excel("1-绘图.xlsx")

# ===== 因子顺序 =====
data$Virus <- factor(data$Virus,
                     levels = paste0("v", 1:2166))

data$Group <- factor(data$Group,
                     levels = c("DMS lib.", "palate", "lung"))

# ===== 生成颜色（去重 + 循环填充）=====
base_colors <- c(
  "#e86502", "#9ed84e", "#39ba30", "#6ad157", "#8249aa", "#99db27", "#e07233", "#ff523f",
  "#ce2523", "#f7aa5d", "#cebb10", "#03827f", "#931635", "#373bbf", "#a1ce4c", "#ef3bb6",
  "#d66551", "#1a918f", "#ff66fc", "#2927c4", "#7149af", "#57e559", "#8e3af4", "#f9a270",
  "#22547f", "#db5e92", "#edd05e", "#6f25e8", "#0dbc21", "#280f7a", "#6373ed", "#5b910f",
  "#7b34c1", "#0cf29a", "#d80fc1", "#dd27ce", "#07a301", "#167275", "#391c82", "#2baeb5",
  "#925bea", "#63ff4f", "#ed9529", "#31a3b8", "#6d2947", "#a48c2a", "#c37d8c", "#4cb188",
  "#9f2070", "#62b52f", "#b131a1", "#ad7117", "#156a72", "#a2a64e", "#b45854", "#6eb06d",
  "#3d3c95", "#956c3a", "#1f7b51", "#b96ca2", "#6e9430", "#af2e2e", "#328360", "#6e4764",
  "#cf8232", "#7a4b30", "#326e7b", "#8a3352", "#b0944f", "#59497b", "#8fb96b", "#603b82",
  "#8fae6c", "#504976", "#d3865f", "#777a37", "#de6292", "#88825f", "#c4a1b0", "#6C5095",
  "#926057", "#435746", "#bf8696", "#6b8a52", "#715b85", "#7e9f6d", "#86708a", "#598043",
  "#89616c", "#4d8166", "#806353", "#B53600", "#FF6B6B", "#4ECDC4", "#556270", "#C7F464", 
  "#C44D58", "#FFA07A", "#20B2AA", "#9370DB", "#3CB371", "#FFB347", "#87CEFA", "#FF69B4", 
  "#8B4513", "#2E8B57", "#FFD700", "#00CED1", "#DC143C", "#4682B4", "#9ACD32", "#FF8C00",
  "#8470FF", "#09f9f5", "#246b93", "#cc8e12", "#d561dd", "#c93f00", "#ddd53e", "#4aef7b"
)

virus_colors <- rep(base_colors, length.out = 2166)
names(virus_colors) <- paste0("v", 1:2166)

# ===== 去掉全为0的数据 =====
data <- data %>%
  group_by(Virus) %>%
  filter(sum(Proportion) > 0) %>%
  ungroup()

# ===== 绘图 =====
g <- ggplot(data,
            aes(x = Group,
                y = Proportion,
                fill = Virus,
                stratum = Virus,
                alluvium = Virus)) +
  
  geom_col(width = 0.8, color = NA) +
  
  geom_flow(width = 1/3,
            alpha = 0.8,
            knot.pos = 0.4) +
  
  scale_fill_manual(values = virus_colors) +
  
  theme_map() +
  
  theme(
    axis.text.x = element_text(size = 12, vjust = 0.5),
    axis.title = element_text(size = 12),
    legend.position = "none",
    
    panel.border = element_rect(color = "black",
                                fill = NA,
                                size = 0.8)
  ) +
  
  labs(x = NULL, y = "Proportion") +   # ✅ 只去掉“Group”
  
  coord_cartesian(expand = FALSE)

# ===== 显示 =====
print(g)

# ===== 保存为 PDF =====
ggsave("G:/1-桑基图_aa/palate4.pdf",
       plot = g,
       width = 2.3,
       height = 2.2)