library("ggVennDiagram")
library("ggvenn")
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)

vennlist <- list()
nam <- c()
tilte <- ""
regulate <- ""
for (input in args){
	data <- read.table(input, header = F, sep = "\t", quote = "")
	input <- strsplit(input, split = "/")
	input <- sapply(input, tail, 1)
	#print (data$V1)
	#print(vennlist)
	
	name <- ((strsplit(input, split = "[.]"))[[1]])[1]
	#print(name)
	regulate <- ((strsplit(input, split = "__"))[[1]])[3]
	regulate <- ((strsplit(regulate, split = "[.]|_"))[[1]])[2]
	print (regulate)
	nam <- c(nam, name)
	vennlist[[name]] <- data$V1
	title <- ((strsplit(input, split = "__"))[[1]])[1]
}

if(FALSE){
p <- ggVennDiagram(vennlist,
		   label = "count",
		   edge_size = 0,
		   category.names = nam,
		   set_size = 3, ) + 
scale_colour_brewer(palette = "Set1")
#scale_colour_manual(values=c("red", "blue")) + theme(legend.position = 'none')
#scale_fill_gradient(low="blue",high = "red", name = "gene count")
}
p <- ggvenn(vennlist, show_percentage = FALSE, set_name_size = 3, stroke_size = 0, fill_color = c("blue", "green", "yellow", "red"),)
ggsave(paste(title, regulate, "vennDiagram.pdf", sep = "_"), p)
ggsave(paste(title, regulate, "vennDiagram.png", sep = "_"), p)
