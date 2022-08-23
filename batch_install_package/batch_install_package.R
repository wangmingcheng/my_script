args <- commandArgs(T)

packages_info <- read.table(args[1])
packages_list <- packages_info[, 1]

ipak <- function(pkg){
 	new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
 	if (length(new.pkg)) 
 		install.packages(new.pkg, dependencies = TRUE, repos = "https://mirrors.sjtug.sjtu.edu.cn/cran/")
 	sapply(pkg, require, character.only = TRUE)
}

ipak(packages_list)

print("Done!")
