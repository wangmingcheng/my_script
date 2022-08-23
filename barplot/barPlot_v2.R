library(tidyverse)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)

df <- read_tsv(args[1])

a <- names(df)[1]
print (a)
p <- df %>% pivot_longer(names(df)[-1], values_to = "value") %>% group_by(name) %>% mutate(percentage = value / sum(value)) %>%  ggplot(aes(x = name, y = percentage, fill = category)) + geom_bar(stat = 'identity',colour = "#414141", width = 0.6) + 

labs(x = "", y = "Percentage of eccDNA counts(%)", title = "",face="plain") +
theme_bw() +
theme(axis.text.x = element_text(angle = 45, vjust = 0.5))

ggsave("barplot_v2.png", p)
ggsave("barplot_v2.pdf", p)
