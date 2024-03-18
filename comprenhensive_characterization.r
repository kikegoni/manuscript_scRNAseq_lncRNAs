########################################################### Generic #################################################################################################
#####################################################################################################################################################################
libraries <- c("Seurat","patchwork", "tximport", "ggplot2", "scran" , "scater", "SingleCellExperiment", "BUSpaRse", "DropletUtils", "RColorBrewer", "cluster", "UpSetR","scRNAseq", "ggpubr","scDblFinder","reshape","ggupset","dplyr","readxl","stringr")

lapply(libraries, require, character.only = TRUE)
# Import gtf annotation & setWD, source functions
human_gencode_path <- "~/dato-activo/reference.genomes_kike/GRCh38/gencode/gencode.v37.annotation.gtf"
hg38_ensembl_gtf <- as.data.frame(rtracklayer::import(human_gencode_path))
hg38_ensembl_gtf$gene_id <- gsub("_","-",hg38_ensembl_gtf$gene_id)
lncrna_ens_ids_human <- unique(c(hg38_ensembl_gtf$gene_id[grep("lncRNA",hg38_ensembl_gtf$gene_type)]))
protein_coding_ens_ids_human <- unique(c(hg38_ensembl_gtf$gene_id[hg38_ensembl_gtf$gene_type=="protein_coding"]))
lncrna_names_human <- unique(hg38_ensembl_gtf$gene_name[hg38_ensembl_gtf$gene_id %in% lncrna_ens_ids_human])
protein_coding_names_human <-  unique(hg38_ensembl_gtf$gene_name[hg38_ensembl_gtf$gene_id %in% protein_coding_ens_ids_human])
human_repeatMasker_cleaned_path <- "/home/egonie/dato-activo/reference.genomes_kike/GRCh38/gencode/GRCh38.primary_assembly_GENCODE.genome.fa.out_cleaned.gff"
seekr_6_communities_human_path <- "/home/egonie/dato-activo/reference.genomes_kike/GRCh38/gencode/SEEKR_communities_6mers.csv"

mouse_gencode_path <- "/home/egonie/dato-activo/reference.genomes_kike/GRCm39/gencode/gencode.vM27.annotation.gtf"
mouse_gtf <- as.data.frame(rtracklayer::import(mouse_gencode_path))
mouse_gtf$gene_id <- gsub("_","-",mouse_gtf$gene_id)
lncrna_ens_ids_mouse <- unique(c(mouse_gtf$gene_id[grep("lncRNA",mouse_gtf$gene_type)]))
protein_coding_ens_ids_mouse <- unique(c(mouse_gtf$gene_id[mouse_gtf$gene_type=="protein_coding"]))
lncrna_names_mouse <- unique(mouse_gtf$gene_name[mouse_gtf$gene_id %in% lncrna_ens_ids_mouse])
protein_coding_names_mouse <-  unique(mouse_gtf$gene_name[mouse_gtf$gene_id %in% protein_coding_ens_ids_mouse])
mouse_repeatMasker_cleaned_path <- "/home/egonie/dato-activo/reference.genomes_kike/GRCm39/gencode/GRCm39.primary_assembly.genome.fa.out_cleaned.gff"
seekr_6_communities_mouse_path <- "/home/egonie/dato-activo/reference.genomes_kike/GRCm39/gencode/SEEKR_communities_6mers.csv"

source("/home/egonie/kike/phd/git_rep_hpclogin/manuscript_scRNAseq_lncRNAs/manuscript_functions.r")
setwd("/home/egonie/kike/phd/test_data/paper_figures/figure3_characterization_ex_kallisto")

# Datasets
human_10k_pbmc_path <- "/home/egonie/kike/phd/test_data/paper_figures/figure3_characterization_ex_kallisto/pbmc_datasets_updated.rds"
mouse_1k_brain_path <- "/home/egonie/kike/phd/test_data/paper_figures/figure3_characterization_ex_kallisto/mouse_datasets_completed.rds"
kallisto_figure2_path <- "/home/egonie/kike/phd/test_data/paper_figures/figure3_characterization_ex_kallisto/kallisto_datasets.rds"
cellRanger_figure2_path <- "/home/egonie/kike/phd/test_data/paper_figures/figure3_characterization_ex_kallisto/cellRanger_datasets.rds"

###########################################################################################################################################################
###########################################################################################################################################################
# This is generic data that only needs to be run once. After we will just load this information.
all_info_human <- exonic_length_transcript(hg38_ensembl_gtf)
exons = hg38_ensembl_gtf[hg38_ensembl_gtf$type=="exon",]
last_isoform <- exons[nrow(exons),]
all_info_human[nrow(all_info_human),]=c(last_isoform$gene_id,last_isoform$gene_name,last_isoform$transcript_id,last_isoform$width)

all_info_mouse <- exonic_length_transcript(mouse_gtf)
exons = mouse_gtf[mouse_gtf$type=="exon",]
last_isoform <- exons[nrow(exons),]
all_info_mouse[nrow(all_info_mouse),]=c(last_isoform$gene_id,last_isoform$gene_name,last_isoform$transcript_id,last_isoform$width)

saveRDS(all_info_human, "/home/egonie/dato-activo/reference.genomes_kike/GRCh38/gencode/transcrips_lengths.rds")
saveRDS(all_info_mouse, "/home/egonie/dato-activo/reference.genomes_kike/GRCm39/gencode/transcrips_lengths.rds")

all_info_human_path <- "/home/egonie/dato-activo/reference.genomes_kike/GRCh38/gencode/transcrips_lengths.rds"
all_info_mouse_path <- "/home/egonie/dato-activo/reference.genomes_kike/GRCm39/gencode/transcrips_lengths.rds"

longest_transcripts_human <- get_longest_transcript(all_info_human_path)
longest_transcripts_mouse <- get_longest_transcript(all_info_mouse_path)

saveRDS(longest_transcripts_human,"longest_transcripts_human.RDS")
longest_transcripts_human <- readRDS("longest_transcripts_human.RDS")
saveRDS(longest_transcripts_mouse,"longest_transcripts_mouse.RDS")
longest_transcripts_mouse <- readRDS("longest_transcripts_mouse.RDS")

# get for every transcript the list of coordinates of its exons
exons_longest_transcripts_human <- transcripts_exons_coordinates(human_gencode_path, longest_transcripts_human)
saveRDS(exons_longest_transcripts_human, "/home/egonie/dato-activo/reference.genomes_kike/GRCh38/gencode/exons_longest_transcripts.rds")
exons_longest_transcripts_human <- readRDS("/home/egonie/dato-activo/reference.genomes_kike/GRCh38/gencode/exons_longest_transcripts.rds")

exons_longest_transcripts_mouse <- transcripts_exons_coordinates(mouse_gencode_path, longest_transcripts_mouse)
saveRDS(exons_longest_transcripts_mouse, "/home/egonie/dato-activo/reference.genomes_kike/GRCm39/gencode/exons_longest_transcripts.rds")
exons_longest_transcripts_mouse <- readRDS("/home/egonie/dato-activo/reference.genomes_kike/GRCm39/gencode/exons_longest_transcripts.rds")

# Get the number of exons for the longest isoform of each gene
n_exons_human <- number_of_exons_longest_isoform(hg38_ensembl_gtf, longest_transcripts_human)
saveRDS(n_exons_human, "number_exons_human.RDS")
n_exons_human <- readRDS("number_exons_human.RDS")

n_exons_mouse <- number_of_exons_longest_isoform(mouse_gtf, longest_transcripts_mouse)
saveRDS(n_exons_mouse, "number_exons_mouse.RDS")
n_exons_mouse <- readRDS("number_exons_mouse.RDS")

# Load repeats from repeatMasker
human_repeats_cleaned <- rtracklayer::import(human_repeatMasker_cleaned_path)
mouse_repeats_cleaned <- rtracklayer::import(mouse_repeatMasker_cleaned_path)

# load SEEKR data: For analyzing function of lncRNAs according to k-mer content
seekr_6_communities_human <- load_SEEKR_communities(seekr_6_communities_human_path, hg38_ensembl_gtf)
seekr_6_communities_mouse <- load_SEEKR_communities(seekr_6_communities_mouse_path, mouse_gtf)

# load crispr data
#CRISPR public data from paper https://www.science.org/doi/10.1126/science.aah7111 (~500 lncRNAs proved to participate in cell growth)
crispr_data <- readRDS("/home/egonie/kike/databases/hits_info_Liu_science_2015_ensids.rds")

############################################################################################################################
############ For every dataset generate the df_vp matrix with the info about the cell specificity and expression ###########
############################################################################################################################
threshold_minumun_gene_counts_v <- c(250,100,50,25)
threshold_cells_detected_v <- c(25,10,5,3)

############################################################################################################################
##################################################### Human 10k PBMCs ######################################################
############################################################################################################################
pbmc_datasets_updated <- readRDS(human_10k_pbmc_path)
cellRanger_sce_filt_clus <- pbmc_datasets_updated[["cellRanger"]]
STARsolo_sce_filt_clus <- pbmc_datasets_updated[["STARsolo"]]
kallisto_sce_filt_clus <- pbmc_datasets_updated[["kallisto"]]
alevin_sce_filt_clus <- pbmc_datasets_updated[["Alevin"]]

#get universe of genes
universe_genes <- intersect(rownames(kallisto_sce_filt_clus),rownames(alevin_sce_filt_clus))
cellRanger_sce_filt_clus <- cellRanger_sce_filt_clus[universe_genes,]
STARsolo_sce_filt_clus <- STARsolo_sce_filt_clus[universe_genes,]
kallisto_sce_filt_clus <- kallisto_sce_filt_clus[universe_genes,]
alevin_sce_filt_clus <- alevin_sce_filt_clus[universe_genes,]

# Gene length distribution:
length_PBMCs <- length_distributions(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_sce_filt_clus, cellRanger_sce_filt_clus, STARsolo_sce_filt_clus, alevin_sce_filt_clus, lncrna_names_human, protein_coding_names_human,longest_transcripts=longest_transcripts_human,gene_name="gene_name")

# Number of exons
number_exons_PBMCs <- number_exons_distributions(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_sce_filt_clus, cellRanger_sce_filt_clus, STARsolo_sce_filt_clus, alevin_sce_filt_clus, lncrna_names_human, protein_coding_names_human,n_exons_all=n_exons_human,gene_name="gene_name")

# Repeat content
final_repeats_percentage_PBMCs <- repeats_results(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_sce_filt_clus, cellRanger_sce_filt_clus, STARsolo_sce_filt_clus, alevin_sce_filt_clus,lncrna_names_human,protein_coding_names_human,hg38_repeats=human_repeats_cleaned, exons_longest_transcript = exons_longest_transcripts_human)
ratio_repeats_hg_10k_PBMCs <- ratios_repeats(final_repeats_percentage_PBMCs,"hg_10k_PBMCs")

# K-mer analysis (SEEKR)
seekr_results_hg_10k_PBMCs <- SEEKR_results(threshold_minumun_gene_counts_v, threshold_cells_detected_v, kallisto_sce_filt_clus, cellRanger_sce_filt_clus, STARsolo_sce_filt_clus, alevin_sce_filt_clus, seekr_6_communities_human,lncrnas_ids = lncrna_names_human )

# Specificity index (SI)
df_vp <- create_df_vp(kallisto_sce_filt_clus,cellRanger_sce_filt_clus,STARsolo_sce_filt_clus=STARsolo_sce_filt_clus,alevin_sce_filt_clus=alevin_sce_filt_clus, lncrna_names_human, protein_coding_names_human )
saveRDS(df_vp,"df_vp_PBMC.rds")
df_vp_PBMC <- readRDS("df_vp_PBMC.rds")

# Intersect with bibliographically validated lncRNAs by CRISPRi
all_crispr_data_intersection_PBMCs <- crispr_data_intersection(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_sce_filt_clus, cellRanger_sce_filt_clus, STARsolo_sce_filt_clus, alevin_sce_filt_clus, lncrna_names_human,crispr_data,gene_name="gene_name",hg38_ensembl_gtf)


############################################################################################################################
################################################## 1k Mouse Brain cells ####################################################
############################################################################################################################
mouse_datasets_updated <- readRDS(mouse_1k_brain_path)
cellRanger_sce_filt_clus <- mouse_datasets_updated[["cellRanger"]]
STARsolo_sce_filt_clus <- mouse_datasets_updated[["STARsolo"]]
kallisto_sce_filt_clus <- mouse_datasets_updated[["kallisto"]]
alevin_sce_filt_clus <- mouse_datasets_updated[["Alevin"]] 

#get universe of genes
universe_genes <- intersect(rownames(kallisto_sce_filt_clus),rownames(alevin_sce_filt_clus))
cellRanger_sce_filt_clus <- cellRanger_sce_filt_clus[universe_genes,]
STARsolo_sce_filt_clus <- STARsolo_sce_filt_clus[universe_genes,]
kallisto_sce_filt_clus <- kallisto_sce_filt_clus[universe_genes,]
alevin_sce_filt_clus <- alevin_sce_filt_clus[universe_genes,]

# Gene length distribution:
length_Mouse_Brain <- length_distributions(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_sce_filt_clus, cellRanger_sce_filt_clus, STARsolo_sce_filt_clus, alevin_sce_filt_clus, lncrna_names_mouse, protein_coding_names_mouse,longest_transcripts=longest_transcripts_mouse,gene_name="gene_name")

# Number of exons
number_exons_Mouse_Brain <- number_exons_distributions(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_sce_filt_clus, cellRanger_sce_filt_clus, STARsolo_sce_filt_clus, alevin_sce_filt_clus, lncrna_names_mouse, protein_coding_names_mouse,n_exons_all=n_exons_mouse,gene_name="gene_name")

# Repeat content
final_repeats_percentage_Mouse_Brain <- repeats_results(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_sce_filt_clus, cellRanger_sce_filt_clus, STARsolo_sce_filt_clus, alevin_sce_filt_clus,lncrna_names_mouse,protein_coding_names_mouse,hg38_repeats=mouse_repeats_cleaned, exons_longest_transcript = exons_longest_transcripts_mouse)
ratio_repeats_mm_1k_brain <- ratios_repeats(final_repeats_percentage_Mouse_Brain,"mm_1k_brain")

# K-mer analysis (SEEKR)
seekr_results_mm_1k_brain <- SEEKR_results(threshold_minumun_gene_counts_v, threshold_cells_detected_v, kallisto_sce_filt_clus, cellRanger_sce_filt_clus, STARsolo_sce_filt_clus, alevin_sce_filt_clus, seekr_6_communities_mouse,lncrnas_ids = lncrna_names_mouse )

# Specificity index (SI)
df_vp_Mouse_Brain <- create_df_vp(kallisto_sce_filt_clus,cellRanger_sce_filt_clus,STARsolo_sce_filt_clus=STARsolo_sce_filt_clus,alevin_sce_filt_clus=alevin_sce_filt_clus, lncrna_names_mouse, protein_coding_names_mouse )
saveRDS(df_vp_Mouse_Brain,"df_vp_Mouse_Brain.rds")
df_vp_Mouse_Brain <- readRDS("df_vp_Mouse_Brain.rds")


##############################################################################################################################################################
###################################################  Datasets extended benchmark  ############################################################################
##############################################################################################################################################################
kallisto_objects <- readRDS(kallisto_figure2_path)
kallisto_intestine_pool1_ed <- kallisto_objects[["intestine1"]]
kallisto_intestine_pool2_ed <- kallisto_objects[["intestine2"]]
kallisto_healthy_lung_ed <- kallisto_objects[["healthy_lung1"]]
kallisto_healthy_lung_GSM4037316_ed <- kallisto_objects[["healthy_lung2"]]
kallisto_pulmonary_fibrosis_ed <- kallisto_objects[["pulmonary_fibrosis"]]
kallisto_PBMCs_5K_ed <- kallisto_objects[["PBMCs_5K"]]
kallisto_PBMCs_mouse_ed <- kallisto_objects[["PBMCs_mouse"]]

cellRanger_objects <- readRDS(cellRanger_figure2_path)
cellRanger_intestine_pool1_ed <- cellRanger_objects[["intestine1"]]
cellRanger_intestine_pool2_ed <- cellRanger_objects[["intestine2"]]
cellRanger_healthy_lung_ed <- cellRanger_objects[["healthy_lung1"]]
cellRanger_healthy_lung_GSM4037316_ed <- cellRanger_objects[["healthy_lung2"]]
cellRanger_pulmonary_fibrosis_ed <- cellRanger_objects[["pulmonary_fibrosis"]]
cellRanger_PBMCs_5K_ed <- cellRanger_objects[["PBMCs_5K"]]
cellRanger_PBMCs_mouse_ed <- cellRanger_objects[["PBMCs_mouse"]]

# Filtering & normalization
threshold_mito_percentage = 15
high_threshold_cell_counts = 50000
cells_min_genes_detected_threshold = 500

kallisto_intestine_pool1_ed_filt <- Filtering(kallisto_intestine_pool1_ed,  cells_mito_threshold = threshold_mito_percentage, cells_max_threshold = high_threshold_cell_counts, cells_min_genes_detected_threshold = cells_min_genes_detected_threshold)
kallisto_intestine_pool2_ed_filt <- Filtering(kallisto_intestine_pool2_ed,  cells_mito_threshold = threshold_mito_percentage, cells_max_threshold = high_threshold_cell_counts, cells_min_genes_detected_threshold = cells_min_genes_detected_threshold)
kallisto_healthy_lung_ed_filt <- Filtering(kallisto_healthy_lung_ed,  cells_mito_threshold = threshold_mito_percentage, cells_max_threshold = high_threshold_cell_counts, cells_min_genes_detected_threshold = cells_min_genes_detected_threshold)
kallisto_healthy_lung_GSM4037316_ed_filt <- Filtering(kallisto_healthy_lung_GSM4037316_ed,  cells_mito_threshold = threshold_mito_percentage, cells_max_threshold = high_threshold_cell_counts, cells_min_genes_detected_threshold = cells_min_genes_detected_threshold)
kallisto_pulmonary_fibrosis_ed_filt <- Filtering(kallisto_pulmonary_fibrosis_ed,  cells_mito_threshold = threshold_mito_percentage, cells_max_threshold = high_threshold_cell_counts, cells_min_genes_detected_threshold = cells_min_genes_detected_threshold)
kallisto_PBMCs_5K_ed_filt <- Filtering(kallisto_PBMCs_5K_ed,  cells_mito_threshold = threshold_mito_percentage, cells_max_threshold = high_threshold_cell_counts, cells_min_genes_detected_threshold = cells_min_genes_detected_threshold)
kallisto_PBMCs_mouse_ed_filt <- Filtering(kallisto_PBMCs_mouse_ed,  cells_mito_threshold = threshold_mito_percentage, cells_max_threshold = high_threshold_cell_counts, cells_min_genes_detected_threshold = cells_min_genes_detected_threshold)

cellRanger_intestine_pool1_ed_filt <- Filtering(cellRanger_intestine_pool1_ed,  cells_mito_threshold = threshold_mito_percentage, cells_max_threshold = high_threshold_cell_counts, cells_min_genes_detected_threshold = cells_min_genes_detected_threshold)
cellRanger_intestine_pool2_ed_filt <- Filtering(cellRanger_intestine_pool2_ed,  cells_mito_threshold = threshold_mito_percentage, cells_max_threshold = high_threshold_cell_counts, cells_min_genes_detected_threshold = cells_min_genes_detected_threshold)
cellRanger_healthy_lung_ed_filt <- Filtering(cellRanger_healthy_lung_ed,  cells_mito_threshold = threshold_mito_percentage, cells_max_threshold = high_threshold_cell_counts, cells_min_genes_detected_threshold = cells_min_genes_detected_threshold)
cellRanger_healthy_lung_GSM4037316_ed_filt <- Filtering(cellRanger_healthy_lung_GSM4037316_ed,  cells_mito_threshold = threshold_mito_percentage, cells_max_threshold = high_threshold_cell_counts, cells_min_genes_detected_threshold = cells_min_genes_detected_threshold)
cellRanger_pulmonary_fibrosis_ed_filt <- Filtering(cellRanger_pulmonary_fibrosis_ed,  cells_mito_threshold = threshold_mito_percentage, cells_max_threshold = high_threshold_cell_counts, cells_min_genes_detected_threshold = cells_min_genes_detected_threshold)
cellRanger_PBMCs_5K_ed_filt <- Filtering(cellRanger_PBMCs_5K_ed,  cells_mito_threshold = threshold_mito_percentage, cells_max_threshold = high_threshold_cell_counts, cells_min_genes_detected_threshold = cells_min_genes_detected_threshold)
cellRanger_PBMCs_mouse_ed_filt <- Filtering(cellRanger_PBMCs_mouse_ed,  cells_mito_threshold = threshold_mito_percentage, cells_max_threshold = high_threshold_cell_counts, cells_min_genes_detected_threshold = cells_min_genes_detected_threshold)

#gene names features
kallisto_intestine_pool1_ed_filt <- gene_names_sce(kallisto_intestine_pool1_ed_filt, hg38_ensembl_gtf)
kallisto_intestine_pool2_ed_filt <- gene_names_sce(kallisto_intestine_pool2_ed_filt, hg38_ensembl_gtf)
kallisto_healthy_lung_ed_filt <- gene_names_sce(kallisto_healthy_lung_ed_filt, hg38_ensembl_gtf)
kallisto_healthy_lung_GSM4037316_ed_filt <- gene_names_sce(kallisto_healthy_lung_GSM4037316_ed_filt, hg38_ensembl_gtf)
kallisto_pulmonary_fibrosis_ed_filt <- gene_names_sce(kallisto_pulmonary_fibrosis_ed_filt, hg38_ensembl_gtf)
kallisto_PBMCs_5K_ed_filt <- gene_names_sce(kallisto_PBMCs_5K_ed_filt, hg38_ensembl_gtf)
kallisto_PBMCs_mouse_ed_filt <- gene_names_sce(kallisto_PBMCs_mouse_ed_filt, mouse_gtf)

cellRanger_intestine_pool1_ed_filt <- gene_names_sce(cellRanger_intestine_pool1_ed_filt, hg38_ensembl_gtf)
cellRanger_intestine_pool2_ed_filt <- gene_names_sce(cellRanger_intestine_pool2_ed_filt, hg38_ensembl_gtf)
cellRanger_healthy_lung_ed_filt <- gene_names_sce(cellRanger_healthy_lung_ed_filt, hg38_ensembl_gtf)
cellRanger_healthy_lung_GSM4037316_ed_filt <- gene_names_sce(cellRanger_healthy_lung_GSM4037316_ed_filt, hg38_ensembl_gtf)
cellRanger_pulmonary_fibrosis_ed_filt <- gene_names_sce(cellRanger_pulmonary_fibrosis_ed_filt, hg38_ensembl_gtf)
cellRanger_PBMCs_5K_ed_filt <- gene_names_sce(cellRanger_PBMCs_5K_ed_filt, hg38_ensembl_gtf)
cellRanger_PBMCs_mouse_ed_filt <- gene_names_sce(cellRanger_PBMCs_mouse_ed_filt, mouse_gtf)

################################################## Intestine pool 1 ##################################################################################
# Gene length distribution:
length_intestine_pool1 <- length_distributions(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_intestine_pool1_ed_filt, cellRanger_intestine_pool1_ed_filt, cellRanger_intestine_pool1_ed_filt, cellRanger_intestine_pool1_ed_filt, lncrna_names_human, protein_coding_names_human,longest_transcripts=longest_transcripts_human,gene_name="gene_name")

# Number of exons
number_exons_intestine_pool1 <- number_exons_distributions(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_intestine_pool1_ed_filt, cellRanger_intestine_pool1_ed_filt, cellRanger_intestine_pool1_ed_filt, cellRanger_intestine_pool1_ed_filt, lncrna_names_human, protein_coding_names_human,n_exons_all=n_exons_human,gene_name="gene_name")

# Repeat content
final_repeats_percentage_intestine_pool1 <- repeats_results(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_intestine_pool1_ed_filt, cellRanger_intestine_pool1_ed_filt, cellRanger_intestine_pool1_ed_filt, cellRanger_intestine_pool1_ed_filt,lncrna_names_human,protein_coding_names_human,hg38_repeats=human_repeats_cleaned, exons_longest_transcript = exons_longest_transcripts_human)
ratio_repeats_intestine_pool1 <- ratios_repeats(final_repeats_percentage_intestine_pool1,"hg_intestine_1")

# K-mer analysis (SEEKR)
seekr_results_intestine_pool1 <- SEEKR_results(threshold_minumun_gene_counts_v, threshold_cells_detected_v, kallisto_intestine_pool1_ed_filt, cellRanger_intestine_pool1_ed_filt, cellRanger_intestine_pool1_ed_filt, cellRanger_intestine_pool1_ed_filt, seekr_6_communities_human,lncrnas_ids = lncrna_names_human )

# Specificity index (SI)
kallisto_intestine_pool1_ed_filt <- red_dim(kallisto_intestine_pool1_ed_filt)
df_vp_intestine_pool1 <- create_df_vp(kallisto_intestine_pool1_ed_filt,cellRanger_intestine_pool1_ed_filt,STARsolo_sce_filt_clus=cellRanger_intestine_pool1_ed_filt,alevin_sce_filt_clus=cellRanger_intestine_pool1_ed_filt, lncrna_names_human, protein_coding_names_human )
saveRDS(df_vp_intestine_pool1,"df_vp_intestine_pool1.rds")
df_vp_intestine_pool1 <- readRDS("df_vp_intestine_pool1.rds")

# Intersect with bibliographically validated lncRNAs by CRISPRi
all_crispr_data_intersection_intestine_pool1 <- crispr_data_intersection(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_intestine_pool1_ed_filt, cellRanger_intestine_pool1_ed_filt, cellRanger_intestine_pool1_ed_filt, cellRanger_intestine_pool1_ed_filt, lncrna_names_human,crispr_data,gene_name="gene_name",hg38_ensembl_gtf)

################################################## Intestine pool 2 ##################################################################################
# Gene length distribution:
length_intestine_pool2 <- length_distributions(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, lncrna_names_human, protein_coding_names_human,longest_transcripts=longest_transcripts_human,gene_name="gene_name")

# Number of exons
number_exons_intestine_pool2 <- number_exons_distributions(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, lncrna_names_human, protein_coding_names_human,n_exons_all=n_exons_human,gene_name="gene_name")

# Repeat content
final_repeats_percentage_intestine_pool2 <- repeats_results(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt,lncrna_names_human,protein_coding_names_human,hg38_repeats=human_repeats_cleaned, exons_longest_transcript = exons_longest_transcripts_human)
ratio_repeats_intestine_pool2 <- ratios_repeats(final_repeats_percentage_intestine_pool2,"hg_intestine_2")

# K-mer analysis (SEEKR)
seekr_results_intestine_pool2 <- SEEKR_results(threshold_minumun_gene_counts_v, threshold_cells_detected_v, kallisto_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, seekr_6_communities_human,lncrnas_ids = lncrna_names_human )

# Specificity index (SI)
kallisto_intestine_pool2_ed_filt <- red_dim(kallisto_intestine_pool2_ed_filt)
df_vp_intestine_pool2 <- create_df_vp(kallisto_intestine_pool2_ed_filt,cellRanger_intestine_pool2_ed_filt,STARsolo_sce_filt_clus=cellRanger_intestine_pool2_ed_filt,alevin_sce_filt_clus=cellRanger_intestine_pool2_ed_filt, lncrna_names_human, protein_coding_names_human )
saveRDS(df_vp_intestine_pool2,"df_vp_intestine_pool2.rds")
df_vp_intestine_pool2 <- readRDS("df_vp_intestine_pool2.rds")

# Intersect with bibliographically validated lncRNAs by CRISPRi
all_crispr_data_intersection_intestine_pool2 <- crispr_data_intersection(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, lncrna_names_human,crispr_data,gene_name="gene_name",hg38_ensembl_gtf)




################################################## Mouse PBMCs  ##################################################################################
# Gene length distribution:
length_PBMCs_mouse <- length_distributions(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_PBMCs_mouse_ed_filt, cellRanger_PBMCs_mouse_ed_filt, cellRanger_PBMCs_mouse_ed_filt, cellRanger_PBMCs_mouse_ed_filt, lncrna_names_mouse, protein_coding_names_mouse,longest_transcripts=longest_transcripts_mouse,gene_name="gene_name")

# Number of exons
number_exons_PBMCs_mouse <- number_exons_distributions(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_PBMCs_mouse_ed_filt, cellRanger_PBMCs_mouse_ed_filt, cellRanger_PBMCs_mouse_ed_filt, cellRanger_PBMCs_mouse_ed_filt, lncrna_names_mouse, protein_coding_names_mouse,n_exons_all=n_exons_mouse,gene_name="gene_name")

# Repeat content
final_repeats_percentage_intestine_pool2 <- repeats_results(threshold_minumun_gene_counts_v,threshold_cells_detected_v, kallisto_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt,lncrna_names_human,protein_coding_names_human,hg38_repeats=human_repeats_cleaned, exons_longest_transcript = exons_longest_transcripts_human)
ratio_repeats_intestine_pool2 <- ratios_repeats(final_repeats_percentage_intestine_pool2,"hg_intestine_2")

# K-mer analysis (SEEKR)
seekr_results_intestine_pool2 <- SEEKR_results(threshold_minumun_gene_counts_v, threshold_cells_detected_v, kallisto_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, cellRanger_intestine_pool2_ed_filt, seekr_6_communities_human,lncrnas_ids = lncrna_names_human )

# Specificity index (SI)
kallisto_intestine_pool2_ed_filt <- red_dim(kallisto_intestine_pool2_ed_filt)
df_vp_intestine_pool2 <- create_df_vp(kallisto_intestine_pool2_ed_filt,cellRanger_intestine_pool2_ed_filt,STARsolo_sce_filt_clus=cellRanger_intestine_pool2_ed_filt,alevin_sce_filt_clus=cellRanger_intestine_pool2_ed_filt, lncrna_names_human, protein_coding_names_human )
saveRDS(df_vp_intestine_pool2,"df_vp_intestine_pool2.rds")
df_vp_intestine_pool2 <- readRDS("df_vp_intestine_pool2.rds")
