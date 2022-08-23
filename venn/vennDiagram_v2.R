library("optparse")
if(FALSE){
option_list <- list(
    make_option(c("-i", "--inFile"), help="seurat object rds file"),
    make_option(c("-o", "--outPrefix"), help="output prefix, default %default", default="result"),
    make_option(c("-r", "--recluster"), help="whether re-process data and reduce dimensionality use monolce3 pipline, default %default", default=FALSE, type="logical"),
    make_option(c("-b", "--batch"), help="Remove batch effects, estimate the level of background contamination in each batch of cells and subtract it, default is percent.mt and percent.rp; example percent.hb,Phase", type="character"),
    make_option(c("--use_partition"), help="whether plot cell trajactory in different partitions, default %default", default=TRUE, type="logical"),
    make_option(c("--root_type"), help="specifiy a celltype as root"),
    make_option(c("--root_vertex"), help="specifiy a closest_vertex from groupBy_closest_vertex.png as root node, if --root_type is offered, --root_vertex will be ignored", type="integer"),
    make_option(c("--width"), help="image width, default %default", default=8, type="double"),
    make_option(c("--height"), help="image width, default %default", default=6, type="double"),
    make_option(c("--cores"), help="cpus running graph_test(), default %default", default=12, type="integer")
)
opt <- parse_args(OptionParser(option_list=option_list))
}

#eulerr
library("ggVennDiagram")
library("ggvenn")
library(ggplot2)
library("VennDiagram")
library(RColorBrewer)
args <- commandArgs(T)

vennlist <- list()
for (input in args){
	data <- read.table(input, header = F, sep = "\t", quote = "",colClasses = "character")
	input <- strsplit(input, split = "/")
	input <- sapply(input, tail, 1)
	
	name <- ((strsplit(input, split = "[.]"))[[1]])[1]
	print(name)
	vennlist[[name]] <- data$V1
}

if (!dir.exists("ggVennDiagram")){
	dir.create("ggVennDiagram")
}

p1 <- ggVennDiagram(vennlist,
		   label = "count",
		   edge_size = 0,
		   set_size = 3, ) + 
scale_fill_gradient(low="#ffffb2",high = "#b10026")
#scale_fill_distiller(palette = "RdBu")

ggsave(paste("ggVennDiagram", "vennDiagram.pdf", sep = "/"), p1)
ggsave(paste("ggVennDiagram", "vennDiagram.png", sep = "/"), p1)


if (!dir.exists("ggvenn")){
	dir.create("ggvenn")
}
p2 <- ggvenn(vennlist, set_name_size = 3, stroke_size = 0, fill_color = c("blue", "green", "yellow", "red"),)
ggsave(paste("ggvenn", "vennDiagram.pdf", sep = "/"), p2)
ggsave(paste("ggvenn", "vennDiagram.png", sep = "/"), p2)

if (length(vennlist) > 2){
	if (!dir.exists("VennDiagram")){
		dir.create("VennDiagram")
	}
	venn.diagram(x = vennlist,
		     filename = paste("VennDiagram", "vennDiagram.pdf", sep = "/"),
		     disable.logging = FALSE,
		     fill = brewer.pal(length(vennlist), "Pastel2"),
		     col = brewer.pal(length(vennlist), "Pastel2")
	)
	venn.diagram(x = vennlist,
		     filename = paste("VennDiagram", "vennDiagram.png", sep = "/"),
		     disable.logging = FALSE,
		     fill = brewer.pal(length(vennlist), "Pastel2"),
		     col = brewer.pal(length(vennlist), "Pastel2")
	)
}
