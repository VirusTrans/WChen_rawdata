import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import os

# 文件路径
file_path = os.path.expanduser("~/桌面/CW/H9/others.xlsx")

# 读取数据
data_raw = pd.read_excel(file_path, sheet_name=0)
row_names = data_raw.iloc[:, 0].astype(str).tolist()
matrix_data = data_raw.iloc[:, 1:].to_numpy()
df = pd.DataFrame(matrix_data, index=row_names, columns=row_names)

# 只保留下三角，其余为 NaN
df = df.mask(np.triu(np.ones(df.shape), k=1).astype(bool))

# 绘制热图（下三角显示，NaN透明，颜色范围 0.8-1）
plt.figure(figsize=(12, 10))
sns.heatmap(df,
            cmap=sns.color_palette("RdYlBu_r", 100),
            mask=df.isna(),       # NaN 区域透明
            vmin=0.75,             # 颜色最小值
            vmax=1.0,             # 颜色最大值
            xticklabels=False,
            yticklabels=False,
            cbar=True,
            square=True)

plt.title("Nucleotide Similarity Heatmap (others)", fontsize=16)

# 保存热图到 ~/桌面/CW/H9/
output_dir = os.path.expanduser("~/桌面/CW/H9/")
os.makedirs(output_dir, exist_ok=True)
output_file = os.path.join(output_dir, "others.png")
plt.savefig(output_file, dpi=300, bbox_inches="tight")
plt.show()

print(f"热图已保存: {output_file}")
