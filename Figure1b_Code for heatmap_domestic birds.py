import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np
import os

# -----------------------------
# 文件路径
# -----------------------------
file_path = os.path.expanduser("~/桌面/CW/H9/核苷酸/domestic birds.csv")
output_dir = os.path.expanduser("~/桌面/CW/H9/核苷酸/")
os.makedirs(output_dir, exist_ok=True)

# -----------------------------
# 读取 CSV 数据
# -----------------------------
data_raw = pd.read_csv(file_path)
row_names = data_raw.iloc[:, 0].astype(str).tolist()
matrix_data = data_raw.iloc[:, 1:].to_numpy()
df = pd.DataFrame(matrix_data, index=row_names, columns=row_names)

# -----------------------------
# 下三角 + 阈值过滤
# -----------------------------
df = df.mask(np.triu(np.ones(df.shape), k=1).astype(bool))
df_plot = df.copy()
df_plot[df_plot < 0.8] = np.nan  # 小于0.8显示为灰色

# -----------------------------
# 提取年份
# -----------------------------
dates = pd.to_datetime([name.split("|")[0] for name in row_names], errors="coerce")
years = pd.Series(dates.year, index=row_names)

# -----------------------------
# 时间轴显示固定年份
# -----------------------------
time_labels = ["1966-1996", "2000", "2004", "2008", "2012", "2016", "2020", "2024"]

# 找到每个标签在数据中的第一个索引
xticks = []
yticks = []
for label in time_labels:
    if label == "1966-1996":
        idx = years[years <= 1996].index[0]
    else:
        year_int = int(label)
        idx = years[years == year_int].index[0]
    pos = df.index.get_loc(idx) + 0.5
    xticks.append(pos)
    yticks.append(pos)

# -----------------------------
# 设置字体全局为10号
# -----------------------------
mpl.rcParams.update({'font.size': 10})

# -----------------------------
# 绘制热图（rasterized=True 避免 PDF 卡死）
# -----------------------------
plt.figure(figsize=(3.15, 3.15))  # 8cm × 8cm
ax = sns.heatmap(df_plot,
                 cmap=sns.color_palette("RdYlBu_r", 100),
                 mask=df_plot.isna(),
                 vmin=0.8,
                 vmax=1.0,
                 xticklabels=False,
                 yticklabels=False,
                 cbar=True,
                 square=True,
                 rasterized=True)  # 核心参数

plt.title("Nucleotide Similarity Heatmap (domestic birds)", fontsize=10)

# 设置 X/Y 轴时间标签
ax.set_xticks(xticks)
ax.set_xticklabels(time_labels, rotation=90, fontsize=10)
ax.set_yticks(yticks)
ax.set_yticklabels(time_labels, rotation=0, fontsize=10)

# 优化 colorbar
cbar = ax.collections[0].colorbar
cbar.ax.tick_params(labelsize=10)
cbar.ax.set_position([0.92, 0.2, 0.015, 0.6])

# -----------------------------
# 保存图像
# -----------------------------
tiff_file = os.path.join(output_dir, "domestic_birds_with_year_grouped.tiff")
pdf_file = os.path.join(output_dir, "domestic_birds_with_year_grouped.pdf")

plt.savefig(tiff_file, dpi=600, bbox_inches="tight")  # 高分辨率 TIFF
plt.savefig(pdf_file, dpi=300, bbox_inches="tight")   # PDF，热图为栅格，文字保持矢量

plt.show()
print(f"热图已保存: {tiff_file} 和 {pdf_file}")
