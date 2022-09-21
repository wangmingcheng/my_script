
data <- read.table("/home/wangmc/bin/caculate_spearman_cor/wang.txt",sep="\t", header=TRUE)
df <- as.data.frame(data)
for(n in names(df)) {
  print (n\tdf[[n]])
}
