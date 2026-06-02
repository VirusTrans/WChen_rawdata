#!/bin/bash

# 初始化 Conda 环境（确保你已执行过一次 conda init）
source ~/miniconda3/etc/profile.d/conda.sh
conda activate bioenv

# 设置参考基因组路径
REF="BJ16.fasta"

# 构建索引（仅首次执行）
if [ ! -f "${REF}.bwt" ]; then
    echo "构建参考基因组索引..."
    bwa index $REF
fi

# 遍历所有 fastq.gz 文件
for R1 in *R1.fastq.gz; do
    SAMPLE=$(basename "$R1" | sed 's/_R1.fastq.gz//')
    R2="${SAMPLE}_R2.fastq.gz"

    echo "开始处理样本: $SAMPLE"

    # 质控和修剪
    fastp -i $R1 -I $R2 -o trim_${SAMPLE}_R1.fastq.gz -O trim_${SAMPLE}_R2.fastq.gz \
          -q 20 -w 4 -h ${SAMPLE}_fastp.html -j ${SAMPLE}_fastp.json

    # 比对
    bwa mem $REF trim_${SAMPLE}_R1.fastq.gz trim_${SAMPLE}_R2.fastq.gz > ${SAMPLE}.sam

    # SAM 转 BAM
    samtools view -Sb ${SAMPLE}.sam > ${SAMPLE}.bam

    # 排序
    samtools sort ${SAMPLE}.bam -o ${SAMPLE}_sort.bam

    # 创建索引
    samtools index ${SAMPLE}_sort.bam

    # SNP 变异检测（保留重复，不进行去重）
    lofreq call -f $REF -o ${SAMPLE}.vcf ${SAMPLE}_sort.bam

    # 输出测序深度信息
    samtools depth -a ${SAMPLE}_sort.bam > ${SAMPLE}.depth.txt

    echo "完成样本: $SAMPLE"
    echo "--------------------------"
done

echo "✅ 所有样本处理完成（保留重复，进行SNP分析）！"
