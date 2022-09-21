grep -v "#" Best_GG.collinearity | awk -F "\t" 'BEGIN{print "Grape""\t""Grape.ref";}{print $2,$3}' OFS="\t"  > gene_pair.list
