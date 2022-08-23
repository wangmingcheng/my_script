library("ggplot2")

args <- commandArgs(trailingOnly = TRUE)

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
