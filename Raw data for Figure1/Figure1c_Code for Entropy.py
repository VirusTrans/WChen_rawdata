import os
import math
import pandas as pd
import numpy as np
from collections import Counter, defaultdict
from Bio import SeqIO
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib as mpl
import re
from matplotlib.colors import LinearSegmentedColormap, ListedColormap

def compute_entropy_by_year_heatmap(
        fasta_file, 
        output_dir="~/desktop/CW/H9/熵/熵4/others", 
        output_csv="entropy_by_year.csv", 
        output_heatmap_tiff="entropy_heatmap.tiff",
        output_heatmap_pdf="entropy_heatmap.pdf",
        threshold=0.3):
    """
    计算FASTA文件中每年每个位点的Shannon熵，并保存CSV和热图
    - 最小值 0 为浅蓝色，渐变到黄色、红色
    - 阈值以下非零值显示浅灰色，0 保留颜色
    - X轴每隔40个显示一次位置
    - 图片尺寸8cm×8cm，高分辨率保存
    - 颜色范围固定 0–3
    """

    fasta_file = os.path.expanduser(fasta_file)
    output_dir = os.path.expanduser(output_dir)
    os.makedirs(output_dir, exist_ok=True)

    # -----------------------------
    # 计算 Shannon 熵
    # -----------------------------
    def shannon_entropy(seq_list):
        entropy_list = []
        seq_len = len(seq_list[0])
        for i in range(seq_len):
            valid_aas = [seq[i] for seq in seq_list if seq[i] not in ['X','-','.']]
            total = len(valid_aas)
            if total == 0:
                entropy_list.append(np.nan)
                continue
            counts = Counter(valid_aas)
            entropy = -sum((count/total) * math.log2(count/total) for count in counts.values())
            entropy_list.append(entropy)
        return entropy_list

    # -----------------------------
    # 按年份分类
    # -----------------------------
    sequences_by_year = defaultdict(list)
    for record in SeqIO.parse(fasta_file, "fasta"):
        match = re.search(r'\b(19|20)\d{2}\b', record.id)
        year = int(match.group()) if match else np.nan
        sequences_by_year[year].append(str(record.seq))

    # -----------------------------
    # 计算熵
    # -----------------------------
    entropy_data = {year: shannon_entropy(seqs) for year, seqs in sequences_by_year.items()}
    df = pd.DataFrame(entropy_data)
    df.index.name = "Position"
    df.index = df.index + 1
    df = df[sorted(df.columns)]

    # -----------------------------
    # 保存 CSV
    # -----------------------------
    csv_path = os.path.join(output_dir, output_csv)
    df.to_csv(csv_path, encoding="utf-8-sig")
    print(f"Entropy CSV saved to {csv_path}")

    # -----------------------------
    # 热图数据
    # -----------------------------
    df_plot = df.copy()
    # 阈值以下非零值掩码处理
    mask = (df_plot < threshold) & (df_plot != 0)

    # 自定义渐变色：浅蓝 -> 黄 -> 红
    colors = ["#D3D3D3", "#6495ED", "#FF0000"]  # 浅蓝, 黄, 红
    cmap_main = LinearSegmentedColormap.from_list("custom_entropy", colors, N=100)

    # 为掩码区域设置浅灰色
    cmap = ListedColormap(cmap_main(np.linspace(0,1,100)))
    cmap.set_bad(color="#dcdcdc")  # 阈值以下非零显示灰色

    # -----------------------------
    # 时间分组纵轴
    # -----------------------------
    time_labels = ["1966-1996", "2000", "2004", "2008", "2012", "2016", "2020", "2024"]
    years_sorted = sorted([y for y in df_plot.columns if not pd.isna(y)])
    yticks = []
    for label in time_labels:
        if label == "1966-1996":
            years_in_range = [y for y in years_sorted if y <= 1996]
            if years_in_range:
                idx = df_plot.columns.get_loc(years_in_range[0])
                yticks.append(idx + 0.5)
        else:
            year_int = int(label)
            if year_int in df_plot.columns:
                idx = df_plot.columns.get_loc(year_int)
                yticks.append(idx + 0.5)

    # -----------------------------
    # 绘制热图
    # -----------------------------
    mpl.rcParams.update({'font.size': 10})
    plt.figure(figsize=(3.15, 3.15))  # 8cm × 8cm

    vmin = 0
    vmax = 2.5   # 固定最大值为 3

    ax = sns.heatmap(df_plot.T,
                     cmap=cmap,
                     mask=mask.T,
                     vmin=vmin,
                     vmax=vmax,
                     cbar=True,
                     square=False,
                     rasterized=True)

    plt.xlabel("Position")
    plt.ylabel("Year")
    plt.title("Entropy of Each Position Over Years", fontsize=10)

    # 设置纵轴标签
    ax.set_yticks(yticks)
    ax.set_yticklabels(time_labels, rotation=0, fontsize=10)

    # 设置横轴每 40 个点显示一次
    xticks = np.arange(0, len(df_plot), 40)
    ax.set_xticks(xticks + 0.5)
    ax.set_xticklabels(xticks + 1, rotation=90, fontsize=8)

    # 缩小 colorbar
    cbar = ax.collections[0].colorbar
    cbar.ax.tick_params(labelsize=8)
    cbar.ax.set_position([0.92, 0.25, 0.02, 0.5])

    # -----------------------------
    # 保存图像
    # -----------------------------
    tiff_file = os.path.join(output_dir, output_heatmap_tiff)
    pdf_file = os.path.join(output_dir, output_heatmap_pdf)
    plt.savefig(tiff_file, dpi=600, bbox_inches="tight")
    plt.savefig(pdf_file, dpi=300, bbox_inches="tight")
    plt.show()
    print(f"Entropy heatmap saved: {tiff_file} and {pdf_file}")


# -----------------------------
# 使用示例
# -----------------------------
fasta_file = "~/desktop/CW/H9/熵/熵4/others.fas"
compute_entropy_by_year_heatmap(fasta_file, threshold=0.3)