library(ggplot2)
library(Hmisc)
library(reshape2)
library(plyr)
library(dplyr)
library(ggpubr)


## Summarizes data.
## Gives count, mean, standard deviation, standard error of the mean, and confidence interval (default 95%).
##   data: a data frame.
##   measurevar: the name of a column that contains the variable to be summariezed
##   groupvars: a vector containing names of columns that contain grouping variables
##   na.rm: a boolean that indicates whether to ignore NA's
##   conf.interval: the percent range of the confidence interval (default is 95%)
summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=TRUE,
                      conf.interval=.95, .drop=TRUE) {
  
  # New version of length which can handle NA's: if na.rm==T, don't count them
  length2 <- function (x, na.rm=FALSE) {
    if (na.rm) sum(!is.na(x))
    else       length(x)
  }
  
  # This does the summary. For each group's data frame, return a vector with
  # N, mean, and sd
  datac <- ddply(data, groupvars, .drop=.drop,
                 .fun = function(xx, col) {
                   c(N    = length2(xx[[col]], na.rm=na.rm),
                     mean = mean   (xx[[col]], na.rm=na.rm),
                     sd   = sd     (xx[[col]], na.rm=na.rm)
                   )
                 },
                 measurevar
  )
  
  # Rename the "mean" column    
  datac <- rename(datac, c("mean" = measurevar))
  
  datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
  
  # Confidence interval multiplier for standard error
  # Calculate t-statistic for confidence interval: 
  # e.g., if conf.interval is .95, use .975 (above/below), and use df=N-1
  ciMult <- qt(conf.interval/2 + .5, datac$N-1)
  datac$ci <- datac$se * ciMult
  
  return(datac)
}



###GROUPS LIST
#listGroups<-c("ALL", "OMIM", "CGD","DDG2P")
listGroups<-c("OMIM", "CGD")


for ( group in listGroups ){
  
  #Read table containing allelic counts
  dataTab<-read.table(paste0("/groups/umcg-bios/tmp03/projects/outlierGeneASE/pathogenicAlleles/alleleCountPerGroupPerGene.binom.annotated.alleleFiltered.removedCODAMandOutliers.",group,".txt"), sep="\t", header=TRUE)
  
  #Set empty vector
  pvals <- c()
  nvariants <- c()
  ngenes <- c()
  
  #Annotations to calculate for
  listAnnotation<-c("MODIFIER", "LOW", "MODERATE","HIGH")
  
  totNonOut <- sum(dataTab$NonOutliersTotalAlleles)
  totOut <- sum(dataTab$OutliersTotalAlleles)
  
  #Loop over list of annotations
  for ( anno in listAnnotation ){
    
    #dataTab01 <- dataTab[dataTab$NonOutliersTotalAlleles > 0 & dataTab$OutliersTotalAlleles > 0,] #Only use variants for which both groups have alleles
    
    dataTab1 <- dataTab[dataTab$snpEff_Annotation_Impact == anno,] #Filter category
    
    NonOutAlt <- sum(dataTab1$NonOutliersAltAlleles) #Non-outlier alt alleles for this category
    NonOutTot <- (totNonOut-NonOutAlt) #Non-outlier total alleles (everything minus alt alleles)
    OutAlt <- sum(dataTab1$OutliersAltAlleles) #Outlier alt alleles for this category
    OutTot <- (totOut-OutAlt) #Outlier total alleles (everything minus alt alleles)
    
    cols <- c("Non-outliers", "Outliers")
    nons <- c(NonOutTot,NonOutAlt)
    outs <- c(OutTot,OutAlt)
    
    toTest <- data.frame(nons, outs)
    
    pval <- prop.test(as.matrix(toTest))$p.val
    #Append pvals to vector
    pvals <- c(pvals, pval)
    
    #Append #variants to vector
    nvariant = length(unique(dataTab1$uniq))
    nvariants <- c(nvariants, nvariant)
    ngene = length(unique(dataTab1$gene_id))
    ngenes <- c(ngenes, ngene)
    
    print(paste0("Annotation category: ", anno))
    print(paste0("P-val: ", pval))
  }
  
  
  #Read counts per outlier/non-outlier category
  dataTab2<-read.table(paste0("/groups/umcg-bios/tmp03/projects/outlierGeneASE/pathogenicAlleles/alleleCountPerGroupPerGene.binom.annotated.alleleFiltered.removedCODAMandOutliers.splitOutliers.",group,".txt"), sep="\t", header=TRUE)
  
  #Select variants by snpEff annotation
  dataTab3 <- dataTab2[dataTab2$snpEff_Annotation_Impact %in% c("HIGH", "LOW", "MODERATE","MODIFIER"), ]
  #Only use variants having more than 0 alleles
  #dataTab4 <- dataTab3[dataTab3$TotalAlleles > 0,]
  dataTab4 <- dataTab3
  
  #Calculate proportion of alt alleles
  dataTab4$prop <- (dataTab4$AltAlleles/dataTab4$TotalAlleles)
  #Calculate proportion of carriers
  dataTab4$numCarriers <- (dataTab4$Het+dataTab4$HomAlt)
  dataTab4$propCarriers <- (dataTab4$numCarriers/dataTab4$Total)
  
  
  #Calculate sd, se
  tgc <- summarySE(dataTab4, measurevar="prop", groupvars=c("STATUS","snpEff_Annotation_Impact"))
  
  #Y-max
  tgc$yMax <- (tgc$prop+tgc$se)
  max<-max(tgc$yMax, na.rm=TRUE) #Use this for plotting purpose of labels in graph

  #Set order of impact categories
  tgc$snpEff_Annotation_Impact <- factor(tgc$snpEff_Annotation_Impact, levels=c('MODIFIER','LOW','MODERATE','HIGH'))
  
  #Create plot
  png(paste0("/groups/umcg-bios/tmp03/projects/BIOS_manuscript/suppl/enrichment_alt_alleles_per_impact_category.",group,".png"), width = 1600, height = 1200)

  myplot<-
  ggplot(tgc, aes(x=snpEff_Annotation_Impact, y=prop, fill=STATUS)) + 
          geom_bar(width=0.5, position=position_dodge(width=0.6), stat="identity") +
          geom_errorbar(aes(ymin=prop-se, ymax=prop+se),
                        width=.2,                    # Width of the error bars
                        position=position_dodge(.6))+
          ggtitle(paste0("Enrichment of alternative alleles per impact category for ",group," genes")) +
          ylab('Proportion of alternative alleles')+
          xlab('SnpEff impact categories')+
          theme_pubr()+
          scale_y_continuous(limits = c(0, max*1.3),breaks = scales::pretty_breaks(n = 6))+
          scale_fill_manual(values=c("#999999", "#E69F00"), labels=c('Non-outlier','Outlier'))+
          theme(panel.grid.major = element_line(colour = "grey", size = 0.1),panel.grid.minor = element_line(colour = "grey", size = 0.1), axis.title.x = element_text(size=16), axis.text=element_text(size=16), axis.title.y = element_text(size=16))+
          annotate("label", label = paste("# Variants=",signif(nvariants[1]),"\n# Genes=",signif(ngenes[1]),"\nP-val=",signif(pvals[1], digits = 3)), x = 1, y = max*1.2, size = 3.5, colour = "black") +
          annotate("label", label = paste("# Variants=",signif(nvariants[2]),"\n# Genes=",signif(ngenes[2]),"\nP-val=",signif(pvals[2], digits = 3)), x = 2, y = max*1.2, size = 3.5, colour = "black") +
          annotate("label", label = paste("# Variants=",signif(nvariants[3]),"\n# Genes=",signif(ngenes[3]),"\nP-val=",signif(pvals[3], digits = 3)), x = 3, y = max*1.2, size = 3.5, colour = "black") +
          annotate("label", label = paste("# Variants=",signif(nvariants[4]),"\n# Genes=",signif(ngenes[4]),"\nP-val=",signif(pvals[4], digits = 3)), x = 4, y = max*1.2, size = 3.5, colour = "black")


  #Print plot to output device
  print(myplot)
  dev.off()

}



