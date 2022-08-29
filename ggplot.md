## 火山图（Vocalno Plot）

```
#Rscript volcanoPlot.R group1VSgroup2.Volcano.txt
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

#创建一个分类变量,把上调,下调和不变基的因分为3类用于画图着色
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
```

![](C:\Users\wangm\AppData\Roaming\marktext\images\2022-05-06-13-57-18-Volcano_plot.png)

## GO富集气泡图

```
#Rscript dotplot.R group1VSgroup2.down_GO_BP.enrichment.xls
library("ggplot2")
library("dplyr")

args <- commandArgs(trailingOnly = TRUE)
df <- as.data.frame(read.table(args[1], header = TRUE, sep = "\t", quote = ""))

#显示前20个term
df <- head(subset(df, FDR <= 1e-5), n = 20)
df$TermID <- factor(df$TermID, levels = rev(df$TermID))

p <- ggplot(df, aes(GeneInListInTerm / GeneInTerm, TermID) )+ 
        scale_colour_gradient(low = "green", high = "red") +
        geom_point(aes(size = GeneInListInTerm, color = -log10(Pvalue))) +
        labs(x = "GeneRatio", y = "", title = "Dotplot", color = paste("-log10(", "Pvalue", ")", sep = ""), size = "Gene number", family = "sans") +
        scale_y_discrete(labels = rev(df$TermName)) +
        theme_bw() +
        theme(plot.title = element_text(hjust = 0.5)) 

ggsave("dotplot.png", p)
ggsave("dotplot.pdf", p)
```

![](C:\Users\wangm\AppData\Roaming\marktext\images\2022-05-06-13-57-44-dotplot.png)

## eccDNA长度的累积分布图 ( Empirical Cumulative Density Function)

```
#Rscript ecdfPlot.R ecdfPlot_Data   #给文件目录
library("ggplot2")

args <- commandArgs(trailingOnly = TRUE)

#循环目录下所有文件，然后生成1个数据框
files <- list.files(args[1])
df <- data.frame()
for (data in files){
        df1 <- as.data.frame(read.table(paste0(args[1],"/",data, sep= "" ), header = FALSE, sep = "\t"))        
        df <- rbind(df,df1)
}

p <- ggplot(df, aes(x = V1)) + stat_ecdf(aes(color = V2), geom = "step",) +
     labs(x = "eccDNA size(bp)", y = "Frequency", col = "Samples", title = "ecdfPlot") +
     theme_bw() +
     theme(panel.grid.minor = element_blank(), panel.grid.major = element_blank(), plot.title = element_text(hjust = 0.5))

ggsave("ecdf.png", p)
ggsave("ecdf.pdf", p)
```

## ![](C:\Users\wangm\AppData\Roaming\marktext\images\2022-05-06-14-00-07-ecdf.png)

## eccDNA注释结果统计barplot

```
#Rscript barPlot.R All.category.statistic.xls
library(dplyr)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
df <- read.table(args[1], header=T, row.names=1, sep="\t", na.strings="")

#把矩阵转换成三元组(行名，列名，数值)，即对应(category, sample, value )的格式用于绘图
category <- rep(rownames(df), each = ncol(df))
sample <- rep(colnames(df), times = nrow(df))
value <- unlist(as.data.frame(t(df)))

#调用dplyr中的管道符和函数处理数据并绘图
p <- data.frame(category, sample, value) %>% group_by(sample) %>% summarise(category, sample, value, percentage = value / sum(value), .groups = "keep")  %>% ggplot(aes(x = 
sample, y = percentage, fill = category)) + geom_bar(stat = 'identity',colour = "#414141", width = 0.6) +
labs(x = "", y = "Percentage of eccDNA counts(%)", title = "",face="plain") +
theme_bw() +
theme(axis.text.x = element_text(angle = 45, vjust = 0.5))

ggsave("barplot.png", p)
ggsave("barplot.pdf", p)
```

![](C:\Users\wangm\AppData\Roaming\marktext\images\2022-05-04-20-18-08-barplot.png)

## eccDNA注释结果统计饼图

```
#Rscript pieplot.R  Control-1.anno.category.txt 
library("ggplot2")
library("dplyr")

args <- commandArgs(trailingOnly = TRUE)
data <- read.table(args[1], header = F, sep = "\t") 

p <- data %>% summarise(percentage = V2 / sum(V2), label = paste0(V1,"(", round(percentage * 100, 2), "%)"), .groups = "keep")  %>% ggplot(aes(x = "", y = percentage, fill = label)) +
     geom_bar(stat="identity",width=0.5) +
     coord_polar(theta = "y") +
     labs(x = "", y = "", title = "") +
     theme(axis.text.x = element_blank(), axis.ticks = element_blank(), panel.grid = element_blank(), legend.title = element_blank())

ggsave("pieplot.png", p)
ggsave("pieplot.pdf", p)
```

![](C:\Users\wangm\AppData\Roaming\marktext\images\2022-05-06-13-56-41-pieplot.png)

[R for Data Science](https://r4ds.had.co.nz/index.html)

[ggplot2: elegant graphics for data analysis](https://ggplot2-book.org/)

[Advanced R](https://adv-r.hadley.nz/index.html)

[R Graphics Cookbook, 2nd edition](https://r-graphics.org/)

[R Packages](https://r-pkgs.org/index.html)

[bookdown](https://bookdown.org/)

[tidyverse](https://github.com/tidyverse)

[ggstatplot](https://github.com/IndrajeetPatil/ggstatsplot)

[The Elements of Statistical Learning](https://esl.hohoweiya.xyz//index.html)

[Data Science at the Command Line, 2e](https://datascienceatthecommandline.com/2e/)

[RStudio · GitHub](https://github.com/rstudio)

[knitr: A general-purpose tool for dynamic report generation in R](https://github.com/yihui/knitr)

[Modern R with the tidyverse](https://b-rodrigues.github.io/modern_R/)

[Statistical Inference via Data Science](https://moderndive.netlify.app/index.html)

[The tidyverse style guide](https://style.tidyverse.org/index.html)

[R 数据分析指南与速查手册](https://bookdown.org/xiao/RAnalysisBook/)

[metacran](https://www.r-pkg.org/)

https://github.com/rfordatascience/tidytuesday

https://igraph.org/

/Data2/wangmc/project/ggplot2_practice
