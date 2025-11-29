import pandas as pd
import numpy as np

def gini_simpson_and_shannon_evenness(column):
    total = column.sum()
    if total == 0:
        return pd.Series([0, 0], index=['Gini-Simpson Index', 'Evenness'])

    p = column / total
    p = p[p > 0]
    S = len(p)
    gini = 1 - (p ** 2).sum()
    H = -(p * np.log(p)).sum()
    H_max = np.log(S)
    evenness = H / H_max if H_max > 0 else 0

    return pd.Series([gini, evenness], index=['Gini-Simpson Index', 'Evenness'])

def main():
    file_path = 'E:/7-Gini指数/0-单列汇总.xlsx'
    df = pd.read_excel(file_path)
    result_df = df.apply(gini_simpson_and_shannon_evenness)
    output_file = 'E:/7-Gini指数/gini_shannon_evenness.xlsx'
    result_df.to_excel(output_file, index=True)
    print(f"Gini-Simpson + Shannon Evenness 已计算完毕，并保存至 {output_file}")

if __name__ == "__main__":
    main()
