# BIOS_ASE

## NOTE: We use hardcoded paths to locations of files on our cluster, if you want to do these analysis on your own data you will have to change the paths in the scripts

### Generate count files for haplotype A and B from geneAE data
`sh createCountTables.sh`

### Run binomial test on the a/b counts
`Rscript ASE_binomial_test/binom_test.R`

### Make table with ASE genes (bonf. corrected p-value < 0.05
`python ASE_outlier_table/make_outlier_table.py`

### Perform binominal test on count data
`Rscript binom_sample_ASE_test.all.R`

### Create phenotype table
`perl createPhenotypeTable.pl`

### Merge phenotype table with stats
Merge phenotypedata with the aggregate #genes and #outlier ASE genes from bonferroni corrected logFoldChange matrix

`perl createGenesAndOutliersTable.pl`

### Remove outliers
Select and remove outliers from data, create list with sample IDs to keep

`Rscript removeOutliersAndCODAM.R`

<br><br>
<br><br>
<br><br>


# ASE outlier (genes showing strong ASE) detection

### Remove outliers
Select samples from the table that don't have more than 1000 ASE genes and are not CODAM

`python ASE_outlier_table/select_samples.py`

### Calculate number of ASE genes and outlier genes per sample (using samplelist as obtained from Rscript)
- Only use samples having at least 30X coverage and at least 5X on both haplotypes
- Calculate meand and SD
- Only assess genes for which at least 100 samples show ASE, when a sample is more than 3SD from the mean mark it as outlier for that specific gene

`perl createLogFoldChangeTable.pl`

### Count per gene the number of homs and hets, output in long format
`python allele_count_tables/combine_genes_and_samples.py`

<br><br>
<br><br>
<br><br>


# Minor allele analysis

### Create major/minor allele tables
`perl minor_allele_ratio/createTable.pl`

### Filter out all lines with only NA values from major/minor tables
`perl minor_allele_ratio/filterMatrices.pl`

### Annotate table with CADD information
`module load HTSlib/1.3.2-foss-2015b`

`perl minor_allele_ratio/annotateCountsWithCADD.pl`

### Create impact category plot
Use generated files counts.matrix.m*rAllelle.chrALL.txt.filtered.txt and counts.chr22.addedCADD.txt as input

`Rscript minor_allele_ratio/plot_minor_vs_major_20190129.R`

<br><br>
<br><br>
<br><br>


# Carriers per disease/inheritance (fig 2 and 3)

### Overlap the heterozygous SNPs with the OMIM data to know in which OMIM gene the SNP is located
`python figure_2_and_3/OMIM_enrichment_hetsOnly.py`

### Get the 3 star clinvar variants
`Rscript figure_2_and_3/get_clinvar_pathogenics.R`

### Calcualte enrichment in disease genes
`python figure_2_and_3/enrichment_disease_genes_in_outliers_per_category_hetsOnly.py`

### Make figure 2 and 3
`Rscript figure_2_and_3/plot_carriers_per_clinvar_hetsOnly.R`

<<<<<<< HEAD
<br><br>
<br><br>
<br><br>


# Gene expression analysis and ASE

### Create gene expression table for all samples
`perl geneExpressionTables/selectAllSamplesExcludingCODAMand4outliersForAllGenes.pl`

<br><br>
<br><br>
<br><br>


# Comparison vs GTEx

### Annotate counts with additional information
`perl createAnnotationTableNew.pl`

### Create major/minor table for non-ASE samples
`perl minor_allele_ratio/createTableNonASEsamples.pl`

### Filter table, remove lines containing only NA's
`perl filterMatrices.NonASEsamples.pl`

### Create cumulative count matrices
`perl createCountMatricesCumulativeVariants.pl`

### Create table including GTEx and our counts/ratios
`perl createTables.AlleleAdded.pl`

<br><br>
<br><br>
<br><br>


# Combined gene expression and ASE analysis and plots

### Filter count lists
This is a manual step, can otherwise be done using awk for example.

### Create files used as input for figure 5
`perl figure_5/createASEandGeneExpressionTable/createGeneExpressionAndMinorAlleleRatioTables.ListInput.pl`

<br><br>
<br><br>
<br><br>


# CSV files for ASE-browser
There are 3 tables needed to populate the database
- ase_ase
- ase_sampleAse
- ase_genes

### Create files for tables
`perl ASEbrowserplots/createASEbrowserTablesCsv.pl`

### Create table including all counts
`perl ASEbrowserplots/createSampleAseEntityWithAllCounts.pl`

### Run binomial tests on ase and sampleAse table
`Rscript ASE_binomial_test/binom_snp_aggregate_test.R`

`Rscript ASE_binomial_test/binom_sample_ASE_test.R`

### Split ase_samlpeASE table in smaller chunks, this to produce plots from own laptop (issues with graphial R libraries on cluster)
`perl ASE_binomial_test/splitAse_sampleAseTable.pl`

### Run Rscript to produce plots
`Rscript ASE_binomial_test/manuscript_ASEbrowserPlots.R`

<br><br>
<br><br>
<br><br>


# Plot concordance GoNL DNA vs RNA
`Rscript concordance_GoNL_DNA_vs_RNA.R`

<br><br>
<br><br>
<br><br>


# Pathogenic alleles stratified per disease database

### Create pathogenic allele counts for all variants

`perl pathogenicAlleles/integrateVariantInformationWithAlleleCounts.V2.pl`
`perl pathogenicAlleles/integrateVariantInformationWithAlleleCounts.V3.pl`

### Extract only variants which are present in specific database of interest

`perl pathogenicAlleles/extractOMIMgenesFromAlleleCounts.pl`

`perl pathogenicAlleles/extractOMIMgenesFromAlleleCounts.V3.pl`

`perl pathogenicAlleles/extractCGDgenesFromAlleleCounts.pl`

`perl pathogenicAlleles/extractCGDgenesFromAlleleCounts.V3.pl`

`perl pathogenicAlleles/extractDDG2PgenesFromAlleleCounts.pl`

`perl pathogenicAlleles/extractDDG2PgenesFromAlleleCounts.V3.pl`

### Extract p-values and create plots

`Rscript enrichment_alt_alleles_per_impact_category.R`

`Rscript proportion_alt_alleles_per_variant_impact_category.R`


##Make figure 2 and 3
`Rscript figure_2_and_3/plot_carriers_per_clinvar_hetsOnly.R`

# Analysis of AD pathogenic variants (fig 5)
## plot AD genes
`Rscript figure_5/plot_AD_genes.R`

