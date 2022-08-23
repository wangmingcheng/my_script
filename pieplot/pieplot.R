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
