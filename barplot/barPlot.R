library(dplyr)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
df <- read.table(args[1], header=T, row.names=1, sep="\t", na.strings="")

category <- rep(rownames(df), each = ncol(df))
sample <- rep(colnames(df), times = nrow(df))
value <- unlist(as.data.frame(t(df)))

p <- data.frame(category, sample, value) %>% group_by(sample) %>% summarise(category, sample, value, percentage = value / sum(value), .groups="keep")  %>% ggplot(aes(x = sample, y = percentage, fill = category)) + geom_bar(stat = 'identity',colour = "#414141", width = 0.6) +
labs(x = "", y = "Percentage of eccDNA counts(%)", title = "",face="plain") +
theme_bw() +
theme(axis.text.x = element_text(angle = 45, vjust = 0.5))

ggsave("barplot.png", p)
ggsave("barplot.pdf", p)
