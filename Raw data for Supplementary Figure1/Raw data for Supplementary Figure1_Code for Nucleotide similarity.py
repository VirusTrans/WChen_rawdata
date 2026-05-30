from Bio import SeqIO
import numpy as np
import pandas as pd
import os

# Linux 下展开 ~
fasta_file = os.path.expanduser("~/桌面/CW/H9/domestic birds.fas")
sequences = list(SeqIO.parse(fasta_file, "fasta"))

# 初始化相似性矩阵
n = len(sequences)
similarity_matrix = np.zeros((n, n))

# 计算两两相似性，忽略N和-
for i in range(n):
    seq_i = str(sequences[i].seq).upper()
    for j in range(i, n):
        seq_j = str(sequences[j].seq).upper()
        length = min(len(seq_i), len(seq_j))
        
        # 计算有效比对位置（非N且非-）
        valid_positions = [(a, b) for a, b in zip(seq_i[:length], seq_j[:length]) if a in "ATCG" and b in "ATCG"]
        if valid_positions:
            matches = sum(1 for a, b in valid_positions if a == b)
            similarity = matches / len(valid_positions)
        else:
            similarity = 0  # 没有有效比对位置则相似性为0
        
        similarity_matrix[i, j] = similarity
        similarity_matrix[j, i] = similarity  # 对称矩阵

# 转成DataFrame
seq_ids = [seq.id for seq in sequences]
similarity_df = pd.DataFrame(similarity_matrix, index=seq_ids, columns=seq_ids)

# 保存为 CSV（不会受 Excel 列限制）
output_file = os.path.expanduser("~/桌面/CW/H9/nucleotide_similarity.csv")
similarity_df.to_csv(output_file)
print(f"完成！相似性矩阵已保存为 {output_file}")
