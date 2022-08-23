library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
data <- as.data.frame(read.table(args[1], header = TRUE))

df <- na.omit(data)

cut_off_pvalue <- 0.01      #统计显著性
cut_off_logFC <- 1          #差异倍数值

#统计上调，下调和不变基因的数量
up_num <- nrow(subset(df, log2FoldChange >= cut_off_logFC & padj <= cut_off_pvalue))
down_num <- nrow(subset(df, log2FoldChange <= -cut_off_logFC & padj <= cut_off_pvalue))
normal_num <- nrow(subset(df, (log2FoldChange > -cut_off_logFC & log2FoldChange < cut_off_logFC) | padj > cut_off_pvalue))

#创建一个分类变量,把上调，下调和不变基的因分为3类用于画图着色
df$threshold <- as.factor(ifelse(df$padj < cut_off_pvalue & abs(df$log2FoldChange) >= cut_off_logFC,
                                  ifelse( df$log2FoldChange > cut_off_logFC, paste0('Up:', up_num,collapse = ""), paste0('Down:', down_num, collapse = "")),
                                  paste0('Normal:', normal_num, collapse = "")))

#绘图
p <- ggplot(df, aes(x = log2FoldChange, y = -log10(padj), colour = threshold, fill = threshold )) +
    scale_color_manual(values = c("blue", "grey", "red")) +    
    geom_point(size = 0.5) +
    labs(x = "log2(fold change)", y = "-log10 (p-value)", title = "Volcano Plot") +   
    geom_vline(xintercept = c(-1, 1), col = "black",linetype = "dotted") +
    geom_hline(yintercept = -log10(0.01), col="red",linetype = "dotted") +
    theme_bw() +
    theme(legend.title = element_blank(), panel.grid.minor = element_blank(), panel.grid.major = element_blank(), plot.title = element_text(hjust = 0.5)) 
ggsave("Volcano_plot.pdf", p)
ggsave("Volcano_plot.png", p)
