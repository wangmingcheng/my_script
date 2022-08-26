> df <- data.frame(num = c(1, 2, 3), char = c("a", "b", "c"))
> df
  num char
1   1    a
2   2    b
3   3    c
> names(df)[2] <- "letter"
> df
  num letter
1   1      a
2   2      b
3   3      c
> names(df)[names(df) == "letter"] <- "letter1"
> df
  num letter1
1   1       a
2   2       b
3   3       c
> library(tidyverse)
> df <- df %>% rename(letter2 = letter1)
> df
  num letter2
1   1       a
2   2       b
3   3       c