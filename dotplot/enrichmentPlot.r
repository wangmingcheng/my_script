if (!requireNamespace("optparse", quietly = TRUE))
    install.packages("optparse",repos = "https://mirrors.tuna.tsinghua.edu.cn/CRAN/")
library("optparse")

option_list <- list(
    make_option(c("-i", "--inFile"), help="enrichment file"),
    make_option(c("-b", "--orderBy"), help="order item by Pvalue or FDR, default %default", default="Pvalue"),
    make_option(c("-n", "--number"), help="top item number to plot, default %default", default=20, type="integer"),
    make_option(c("-l", "--itemNameLength"), help="item name will be replaced by '...' if its length > this value, default %default", default=40, type="integer"),
    make_option(c("-c", "--colors"), help="colors of bubbles from low -log10(Pvalue) to high -log10(Pvalue), default %default", default="green,red"),
    make_option(c("--width"), help="image width, default %default", default=8, type="double"),
    make_option(c("--height"), help="image height, default %default", default=6, type="double"),
    make_option(c("--plotTitle"), help="plot title, default %default", default=""),
    make_option(c("--legendTitleFontSize"), help="legend title font size, default %default", default=14, type="double"),
    make_option(c("--legendKeyFontSize"), help="legend key font size, default %default", default=0.5, type="double"),
    make_option(c("--plotTitleFontSize"), help="plot title font size, default %default", default=14.6, type="double"),
    make_option(c("--axisTitleFontSize"), help="axis title font size, default %default", default=12, type="double"),
    make_option(c("--xAxisTextFontSize"), help="x axis text font size, default %default", default=11, type="double"),
    make_option(c("--yAxisTextFontSize"), help="y axis text font size, default %default", default=11, type="double"),
    make_option(c("-p", "--prefix"), help="output prefix, default %default", default="out")
)
opt <- parse_args(OptionParser(option_list=option_list))

##################################################
library(ggplot2)

df <- read.table(opt$inFile, head=T, sep="\t", quote="")

#order dataframe by pvalue or FDR
df <- df[order(df[, opt$orderBy]),]

# select item number to plot
df <- df[1:ifelse(opt$number <= dim(df)[1], opt$number, dim(df)[1]), ]

# turn pvalue or FDR to -log10(pvalue or FDR) 
df$log10P <- -log10(df[, opt$orderBy])

# 324 is the most approximate positive number to 0 that can be expressed in /rainbow/software/anaconda3/envs/rainbow/bin/R
df[df[, "log10P"]==Inf, "log10P"] <- 324 

# item name will be replaced by ”...“ if its length > opt$itemNameLength
df$TermName1 <- apply(df, 1, function(x) { 
    c = unlist(strsplit(x[2], split=''));  
    if(length(c)<=opt$itemNameLength){ 
        x[2] 
    }else{  
        paste(c( c[1:opt$itemNameLength-1], "..."), collapse = '') 
    } 
} )  
df$TermID <- factor(df$TermID, levels=rev(df$TermID), ) # there are some terms with same TermName, so use TermID as x factor

df$richfactor <- df$GeneInListInTerm/df$GeneInTerm

colors = strsplit(opt$colors, split=',')[[1]]

p <- ggplot(df, aes(richfactor, TermID) )+ 
        scale_colour_gradient(low=colors[1], high=colors[2]) +
        geom_point(aes(size=GeneInListInTerm, color=log10P)) +
        labs(x="Rich factor", y="", title=opt$plotTitle, color=paste("-log10(", opt$orderBy, ")", sep=""), size="Gene number", family = "sans") +
	scale_y_discrete(labels = rev(df$TermName1)) +
        theme_bw() +
        theme(
            legend.position="right",
            legend.title=element_text(family="sans", size=opt$legendTitleFontSize),
            legend.key.size=unit(opt$legendKeyFontSize, "cm"),
            axis.title=element_text(family = "sans", size=opt$axisTitleFontSize),
            axis.text.x=element_text(family = "sans", size=opt$xAxisTextFontSize),
            axis.text.y=element_text(family = "sans", size=opt$yAxisTextFontSize),
            plot.title=element_text(family = "sans", hjust=0.5, size=opt$plotTitleFontSize)
        )

ggsave(p, file=paste(opt$prefix, "png", sep="."), width=opt$width, height= opt$height, dpi=500)
ggsave(p, file=paste(opt$prefix, "pdf", sep="."), width=opt$width, height= opt$height, dpi=500)
