setwd('~/DEGs.Multiresolution/')

##
library(scran)
library(scater)
library(ACTIONet)
library(limma)
library(plyr)
library(dplyr)
library(readr)
library(biomaRt)
##########3
brain=readRDS('brain.human.HD.vascular.rds')
meta=read.table('brain.human.HD.vascular.metadata.celltype.txt',header = T,sep = '\t')
brain@meta.data=meta

sce_agg=import.ace.from.Seurat(brain)
rowData(sce_agg)$GeneSymbol=rownames(brain)

## Make quick pseudobulk metadat DF (if relevant metadata already in colData(ace))
pb_metadata = colData(sce_agg)[match(sort(unique(sce_agg$NeuroBioBank.ID)), sce_agg$NeuroBioBank.ID), ] %>% as.data.frame
rownames(pb_metadata) = NULL

## Set filtering criteria
min_cells_per_batch = 10 ## Min cells per sample (per cell type)
min_tot_batches = 4 ## Min total mice (per cell type)
min_batch_per_exp_group = 2 ## Min mice per experimental group (per cell type)
min_batch_frac = 0.01 ## Percentage of cells expressing a gene per mouse (per cell type)
min_kept_genes = 1000 ## Min number of remaining genes after filtering across all mice (per cell type)
min_tot_cells = 50 ## Min number of total cells across experimental groups (per cell type)
## The following are colnames of colData(ace)
split_attr = "main.celltype" ## Cell type labels
batch_attr = "NeuroBioBank.ID" ## Individual mouse labels
exp_group_attr = "Condition" ## Experimental groups (e.g. Control, HD)

## Split ACE/SCE into list of sub-aces by cell type
IDX = ACTIONet:::.get_attr_or_split_idx(sce_agg, sce_agg[[split_attr]]) 
dge.list = lapply(IDX, function(idx){ sce_agg[, idx] })

dge.list = dge.list[sapply(dge.list, ncol) > min_tot_cells]
dge.names = names(dge.list)
dge.list = sapply(dge.names, function(celltype){
  sce = dge.list[[celltype]]
  message(paste(celltype, sep = " - "))
  bIDX = ACTIONet:::.get_attr_or_split_idx(sce, sce[[batch_attr]])
  exp_group_levels = unique(sce[[exp_group_attr]])
  keep_batch = bIDX[sapply(bIDX, length) >= min_cells_per_batch]
  if(length(keep_batch) < min_tot_batches)
    return(NULL)
  pb.nnz.feat = sapply(keep_batch, function(idx){
    ACTIONet::fastRowSums(assays(sce)$counts[, idx] > 0)
  })
  min_frac_pass = sapply(1:ncol(pb.nnz.feat), function(i) pb.nnz.feat[, i]/length(keep_batch[[i]]) >= min_batch_frac)
  keep_genes = apply(min_frac_pass, 1, all)
  
  sce = sce[keep_genes, sce[[batch_attr]] %in% names(keep_batch)]
  if(nrow(sce) < min_kept_genes)
    return(NULL)
  colData(sce) = droplevels(colData(sce))
  rowData(sce) = droplevels(rowData(sce))
  rownames(sce) = rowData(sce)$ENSEMBL
  metadata(sce) = list()
  
  group_count = table(colData(sce)[[exp_group_attr]][match(unique(colData(sce)[[batch_attr]]), colData(sce)[[batch_attr]])])
  min_batch_pass = all(group_count[group_count > 0] >= min_batch_per_exp_group)
  exp_group_pass = all(exp_group_levels %in% names(group_count[group_count > 0]))
  
  if(!exp_group_pass | !min_batch_pass)
    return(NULL)
  invisible(gc())
  return(sce)
}, simplify = F)
dge.list = dge.list[!sapply(dge.list, is.null)]
invisible(gc()) ## Clear RAM

## Check remaining cell types, cells per type, and genes
sapply(dge.list, nrow)
sapply(dge.list, ncol)

# Part 3: Normalize counts and make pseudobulk objects
## Normalize ACE/SCE for DEG analysis (Limma only; use raw counts for DESeq2)
dge.list = lapply(dge.list, function(sce){
  sce = normalize.ace(sce, norm_method = "default") ## Median-scaled library size normalization
  invisible(gc())
  return(sce)
})
invisible(gc())

## Save filtered SCE/ACE lists to file
file_out = "file.rds"
dir.create(dirname(file_out), showWarnings = F, recursive = T)

saveRDS(dge.list, file_out) ## Smaller file size
readr::write_rds(dge.list, file_out) ## Much faster, no compression


## Construct pseudobulk SummarizedExperiment objects per cell type 
pb.lists = sapply(names(dge.list), function(n){
  sce = dge.list[[n]]
  message(n)
  se = get.pseudobulk.SE(sce,
                         sample_attr = "NeuroBioBank.ID", ## Individual mouse label (Must be colname of colData(sce) and colname of "pb_metadata")
                         ensemble = T, ## Preprocess for multiresolution pseudobulk
                         assay = "logcounts", ## Prenormalized assay for DEG analysis
                         bins = 25, ## Number of multiresolution bins
                         col_data = pb_metadata, ## Pseudobulk metadata
                         pseudocount = 0, ## Must be >0 for DESeq
                         with_S = F, ## Compute pseudobulk sums (for DESeq)
                         with_E = T, ## Compute pseudobulk mean (for Limma)
                         with_V = T, ## Compute pseudobulk brain.HD.human.seurat.vascular.metadata.celltype.txt (for Limma)
                         min_cells_per_batch = 25,
                         BPPARAM = BiocParallel::MulticoreParam(12))
  
  ## Add any other covariates as columns of 'se' here
  rownames(se) = rowData(se)$GeneSymbol ## Rows should have unique names
  return(se)
}, simplify = F)

## This part should be part of get.pseudobulk.SE() but currently isn't yet. This re-scales the pseudobulk counts.
pb.lists = lapply(pb.lists, function(se){
  assays(se)$counts = rescale.matrix(assays(se)$counts, F)
  assays(se)$mean = rescale.matrix(assays(se)$mean, F)
  bins = metadata(se)$bins
  norm_slots = c(paste0("S", seq.int(bins)), paste0("E", seq.int(bins)))
  norm_slots = norm_slots[norm_slots %in% names(assays(se))]
  assays(se)[norm_slots] = bplapply(assays(se)[norm_slots], ACTIONet::rescale.matrix, FALSE, BPPARAM = BiocParallel::MulticoreParam(12))
  return(se)
})

# Part 4: Run ensemble pseudobulk DGE
## Run multiresolution Limma
ref_level = "Control" ## Reference for DEG comparison
res.list = sapply(pb.lists, function(se){
  se$Condition = factor(se$Condition) ## Comparison variable must be factor
  se$Condition = relevel(se$Condition, ref_level) ## Set reference level of baseline (IMPORTANT)
  res = run.ensemble.pseudobulk.Limma(se,
                                      design = ~Condition, ## Design formula or model matrix. Comparison variable should be last.
                                      p_adj_method = "fdr", ## p-value correction method
  )
  return(res)
}, simplify = F)

save(res.list,file='res.list.RData')

