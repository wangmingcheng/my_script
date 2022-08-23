library("ggplot2")
library("dplyr")

args <- commandArgs(trailingOnly = TRUE)
df <- as.data.frame(read.table(args[1], header = TRUE, sep = "\t", quote = ""))

df <- head(subset(df, FDR <= 1e-5), n = 20)
df$TermID <- factor(df$TermID, levels = rev(df$TermID), ) # there are some terms with same TermName, so use TermID as x factor

#df$GeneRatio <- df$GeneInListInTerm / df$GeneInTerm

p <- ggplot(df, aes(GeneInListInTerm / GeneInTerm, TermID) )+ 
        scale_colour_gradient(low = "green", high = "red") +
        geom_point(aes(size = GeneInListInTerm, color = -log10(Pvalue))) +
        labs(x = "GeneRatio", y = "", title = "Dotplot", color = paste("-log10(", "Pvalue", ")", sep = ""), size = "Gene number", family = "sans") +
        scale_y_discrete(labels = rev(df$TermName)) +
        theme_bw() +
	theme(plot.title = element_text(hjust = 0.5)) 

ggsave("dotplot.png", p)
ggsave("dotplot.pdf", p)
