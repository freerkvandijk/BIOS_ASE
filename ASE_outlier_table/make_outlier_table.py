# Take the p-values from the binomial test and make a table of outlier samples for downstream analysis

import glob

outliers = {}
not_outliers = {}
genes = set([])
samples = set([])

# Per gene we have a list of samples with the p-value threshold that they show ASE for that gene
for f in glob.glob('/groups/umcg-bios/tmp03/projects/outlierGeneASE/binomialTest/genes/*'):
    with open(f) as input_file:
        header = input_file.readline()
        for line in input_file:
            line = line.replace('"','').strip().split(' ')
            gene = line[1]
            if gene not in outliers:
                outliers[gene] = set([])
            if gene not in not_outliers:
                not_outliers[gene] = set([])
            
            sample = line[2]
            fdr_pval = line[9]

            if float(fdr_pval) < 0.05:
                outliers[gene].add(sample)
            else:
                not_outliers[gene].add(sample)
            genes.add(gene)
            samples.add(sample)

samples = list(samples)
genes = list(genes)
print(len(genes),'number of genes')

with open('/groups/umcg-bios/tmp03/projects/outlierGeneASE/logFoldChangeTables/genotypes_BIOS_LLDeep_Diagnostics_merged_phasing_noRnaEditing.logFoldChange.depthFiltere.BINOM.txt','w') as out:
    out.write('ENSEMBLID')
    for sample in samples:
        out.write('\t'+sample)
    out.write('\n')
    for gene in genes:
        out.write(gene)
        for sample in samples:
            if sample in outliers[gene]:
                out.write('\tYES')
            elif sample in not_outliers[gene]:
                out.write('\tNO')
            else:
                out.write('\tNA')
        out.write('\n')
