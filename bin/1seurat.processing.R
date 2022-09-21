#!/usr/bin/env Rscript
setwd('~/analysis')

##########################
library(scales)
library(plyr)
library(Seurat)
library(dplyr)
library(patchwork)
##################################
df=read.table('..//data/sampleinfo.txt',header = T,sep = '\t')
rownames(df)=df$SampleID
#################################

folder='../data/'
files=list.files(path=folder)

ids=c()
finaldata=c()
for (f in files){
  dd=paste(paste(folder,f,sep=''),'/filtered_feature_bc_matrix',sep='')
  data=Read10X(data.dir = dd)
  colnames(data)=paste(f,c(1:ncol(data)),sep='.')
  finaldata=cbind(finaldata,data)
  ids=c(ids,rep(f,ncol(data)))
}

meta=df[ids,]
rownames(meta)=colnames(finaldata)
saveRDS(finaldata,file='brain.BBB.human.counts.rds')
saveRDS(meta,file='brain.BBB.human.meta.rds')
###
id='brain.BBB.human.seurat'
#########
#knownmarker=read.table('~/Dropbox (MIT)/work/dataset/brain/vascular.mouse/markers_cluster.paper.human.txt',header = T,sep = '\t')
knownmarker=read.table('~/data/datasets/markersets/markers_cluster.paper.human.txt',header = T,sep = '\t')
knowngenes=as.character(knownmarker[,3])
###############

## 

data=readRDS('brain.BBB.human.counts.rds')
meta=readRDS('brain.BBB.human.meta.rds')
brain=CreateSeuratObject(counts = data, project = "BBB", meta.data=meta,min.cells = 3, min.features = 200)

brain


## filter
brain[["percent.mt"]] <- PercentageFeatureSet(brain, pattern = "^MT-")
VlnPlot(brain, features = c("nFeature_RNA", "nCount_RNA", "percent.mt"), ncol = 3)
brain <- subset(brain, subset = nFeature_RNA > 500 & nFeature_RNA < 8000 & percent.mt < 10)
brain
## normalization
brain <- NormalizeData(brain, normalization.method = "LogNormalize", scale.factor = 10000)

## feature selction
brain <- FindVariableFeatures(brain, selection.method = "vst", nfeatures = 2000)

# Identify the 10 most highly variable genes
top10 <- head(VariableFeatures(brain), 10)

# plot variable features with and without labels
plot1 <- VariableFeaturePlot(brain)
plot2 <- LabelPoints(plot = plot1, points = top10, repel = TRUE)
CombinePlots(plots = list(plot1, plot2))

## scaling the data
all.genes <- rownames(brain)
brain <- ScaleData(brain, features = all.genes)

## Perform linear dimensional reduction
brain <- RunPCA(brain, features = VariableFeatures(object = brain))
DimPlot(brain, reduction = "pca")

## Determine the ‘dimensionality’ of the dataset
JackStrawPlot(brain, dims = 1:50)
ElbowPlot(brain,ndims = 50)

k=1:30
## cluster the cells
brain <- FindNeighbors(brain, dims = k,k.param = 20)
brain <- FindClusters(brain, resolution = 0.5)
head(Idents(brain), 5)

## Run non-linear dimensional reduction (UMAP/tSNE)
md=0.75
brain <- RunUMAP(brain, dims = k, min.dist=md)
#
brain <- RunUMAP(brain, dims = k)

DimPlot(brain, reduction = "umap",label=T)
DimPlot(brain, reduction = "umap",label=F,group.by = 'SampleID')
DimPlot(brain, reduction = "umap",label=F,group.by = 'PatientID')
DimPlot(brain, reduction = "umap",label=F,group.by = 'snRNAPreparation')

genes=intersect(rownames(brain),knowngenes)
pdf(file=paste(id,'.umap.knownMarkers.pdf',sep=''),width = 8,height = 7)
for (g in genes){
  print(FeaturePlot(brain, features = g))
}
dev.off()


## doublet detection
library(DoubletFinder)
sweep.res.list <- paramSweep_v3(brain, PCs = 1:30, sct = FALSE)
sweep.stats <- summarizeSweep(sweep.res.list, GT = FALSE)
bcmvn <- find.pK(sweep.stats)

## choose pK per best practices outlined on github
pN = 0.25
pK <- as.numeric(as.vector(bcmvn[which.max(bcmvn$BCmetric), ]$pK))

## Homotypic Doublet Proportion Estimate -------------------------------------------------------------------------------------
annotations=brain@meta.data$seurat_clusters
homotypic.prop <- modelHomotypic(annotations)           ## ex: annotations <- seu_kidney@meta.data$ClusteringResults
nExp_poi <- round(0.075*ncol(brain)) ## Assuming 7.5% doublet formation rate - tailor for your dataset
nExp_poi.adj <- round(nExp_poi*(1-homotypic.prop))

## Run DoubletFinder with varying classification stringencies ----------------------------------------------------------------
brain <- doubletFinder_v3(brain, PCs = 1:30, pN = pN, pK = pK, nExp = nExp_poi, reuse.pANN = FALSE, sct = FALSE)
brain <- doubletFinder_v3(brain, PCs = 1:30, pN = pN, pK = pK, nExp = nExp_poi.adj, reuse.pANN = F, sct = FALSE)

meta=brain@meta.data
colnames(meta)[ncol(meta)-2]='DF.classifications'
brain@meta.data=meta

### filtering
cells=rownames(meta[meta$DF.classifications=='Singlet',])
brain <- subset(brain, cells = cells)
brain

brain <- FindVariableFeatures(brain, selection.method = "vst", nfeatures = 2000)

brain <- RunPCA(brain, features = VariableFeatures(object = brain))
DimPlot(brain, reduction = "pca")

brain <- FindNeighbors(brain, dims = k)
brain <- FindClusters(brain, resolution = 0.5)
head(Idents(brain), 5)

## Run non-linear dimensional reduction (UMAP/tSNE)
brain <- RunUMAP(brain, dims = k)
DimPlot(brain, reduction = "umap",label=T)
DimPlot(brain, reduction = "umap",label=F,group.by = 'condition')
DimPlot(brain, reduction = "umap",label=F,group.by = 'sampleID')

table(brain$seurat_clusters)
id=paste(id,'filtered',sep='.')

pdf(file=paste(id,'.umap.pdf',sep=''),width = 6,height = 5)
DimPlot(brain, reduction = "umap",label=T)
DimPlot(brain, reduction = "umap",label=F,group.by = 'condition')
DimPlot(brain, reduction = "umap",label=F,group.by = 'sampleID')
dev.off()

genes=intersect(as.character(knownmarkers$marker),rownames(brain))
pdf(file=paste(id,'.umap.knownMarkers.pdf',sep=''),width = 6,height = 5)
for (g in genes){
  print(FeaturePlot(brain, features = g))
}
dev.off()

## Finding differentially expressed genes (cluster biomarkers)
markers <- FindAllMarkers(object = brain, only.pos = TRUE, min.pct = 0.25, thresh.use = 0.25)
write.table(markers,file=paste(id,'.clusterDEGs.txt',sep = ''),sep='\t',quote=F)
table(markers$cluster)
saveRDS(brain,file=paste(id,'.rds',sep=''))

############## batch correction
###########################
id='brain.BBB.human.seurat.harmony'
##########################
library(scales)
library(plyr)
library(Seurat)
library(dplyr)
library(harmony)
library(pheatmap)
library(RColorBrewer)
rwb <- colorRampPalette(colors = c("blue", "white", "red"))(100)
ryb=colorRampPalette(rev(brewer.pal(n = 10, name ="RdYlBu")))(100)
#####################################
brain <- brain %>% RunHarmony("SampleID", plot_convergence = TRUE)
harmony_embeddings <- Embeddings(brain, 'harmony')
harmony_embeddings[1:5, 1:5]

options(repr.plot.height = 5, repr.plot.width = 12)
DimPlot(object = brain, reduction = "harmony", pt.size = .1, group.by = "SampleID", do.return = TRUE)


brain <- brain %>%
  RunUMAP(reduction = "harmony", dims = k) %>%
  FindNeighbors(reduction = "harmony", dims = k) %>%
  FindClusters(resolution = 0.5) %>%
  identity()

table(Idents(brain))
pdf(file=paste(id,'.umap.pdf',sep=''),width = 8,height = 7)
DimPlot(brain, reduction = "umap",label=T)
DimPlot(brain, reduction = "umap",label=F,group.by = 'SampleID')
DimPlot(brain, reduction = "umap",label=F,group.by = 'PatientID')
DimPlot(brain, reduction = "umap",label=F,group.by = 'snRNAPreparation')
dev.off()

genes=intersect(rownames(brain),knowngenes)
pdf(file=paste(id,'.umap.knownMarkers.pdf',sep=''),width = 8,height = 7)
for (g in genes){
  print(FeaturePlot(brain, features = g))
}
dev.off()

saveRDS(brain,file=paste(id,'.rds',sep=''))
write.table(brain@meta.data,file=paste(id,'.metadata.txt',sep=''),sep = '\t',quote=F)

# find markers for every cluster compared to all remaining cells, report only the positive ones
brain.markers <- FindAllMarkers(brain, only.pos = TRUE, min.pct = 0.25, logfc.threshold = 0.25)
top5=brain.markers %>% group_by(cluster) %>% top_n(n = 5, wt = avg_logFC)
table(brain.markers$cluster)
write.table(brain.markers,file=paste(id,'.clusterDEGs.txt',sep=''),sep = '\t',quote = F)
write.table(top5,file=paste(id,'.clusterDEGs_top5.txt',sep=''),sep = '\t',quote = F)

