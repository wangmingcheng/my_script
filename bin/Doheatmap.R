brary(dplyr)
library(Seurat)
library(ggplot2)
library(patchwork)
library(ggsci)
library(circlize)
library(RColorBrewer)
library(ComplexHeatmap)

# Load the PBMC dataset
pbmc.data <- Read10X(data.dir = "./hg19/")

# Initialize the Seurat object with the raw (non-normalized data).
pbmc <- CreateSeuratObject(counts = pbmc.data,
                                                      project = "pbmc3k",
                                                                                 min.cells = 3,
                                                                                 min.features = 200)
pbmc
# An object of class Seurat
# 13714 features across 2700 samples within 1 assay
# Active assay: RNA (13714 features, 0 variable features)

# calculate mitocondro genes percent
pbmc[["percent.mt"]] <- PercentageFeatureSet(pbmc, pattern = "^MT-")

# filter
pbmc <- subset(pbmc, subset = nFeature_RNA > 200 & nFeature_RNA < 2500 & percent.mt < 5)

# standard process
pbmc <- NormalizeData(pbmc) %>%
      FindVariableFeatures(selection.method = "vst", nfeatures = 2000)

  pbmc <- pbmc %>%
        ScaleData(features = rownames(pbmc)) %>%
          RunPCA(features = VariableFeatures(object = pbmc)) %>%
            FindNeighbors(dims = 1:10) %>%
              FindClusters(resolution = 0.5)

# find markers for every cluster compared to all remaining cells
# report only the positive ones
          pbmc.markers <- FindAllMarkers(pbmc,
                                                                        only.pos = TRUE,
                                                                                                       min.pct = 0.25,
                                                                                                       logfc.threshold = 0.25)

# get top 10 genes
          top5pbmc.markers <- pbmc.markers %>%
                group_by(cluster) %>%
                  top_n(n = 5, wt = avg_log2FC)

col <- pal_npg()(9)

# plot
DoHeatmap(pbmc,features = top5pbmc.markers$gene,
                    group.colors = col) +
  scale_colour_npg() +
    scale_fill_gradient2(low = '#0099CC',mid = 'white',high = '#CC0033',
                                                name = 'Z-score')
