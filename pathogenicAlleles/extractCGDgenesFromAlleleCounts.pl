#!/usr/bin/perl -w
use strict;
use warnings;
use diagnostics;
use List::Util qw(min max);
use List::Util qw(sum);
use File::Glob ':glob';
use File::Basename;
use Getopt::Long;
use Scalar::Util qw(looks_like_number);
use lib '/home/umcg-fvandijk/perl_modules/';
use lib '/home/umcg-fvandijk/perl_modules/lib/perl5/';

my $tabixPath="/apps/software/HTSlib/1.3.2-foss-2015b/bin/";


#Read CGD database CGD.20171220.txt

open(CGD, "< /groups/umcg-bios/tmp03/projects/outlierGeneASE/geneAndVariantLists/CGD.20171220.txt") || die "Can't open file: CGD.20171220.txt!\n";
my @cgdFile = <CGD>;
close(CGD);
my $cgdHeader = $cgdFile[0];
chomp($cgdHeader);
my @cgdHeaderArray = split("\t", $cgdHeader);

my %CGD;
my %CGDanno;
for (my $i=1; $i<=$#cgdFile; $i++){ #loop over lines
    my $line = $cgdFile[$i];
    chomp($line);
    my @array = split("\t", $line); #split line by tab
    my $geneName = $array[0]; #extract gene name
    my $inheritance = $array[4];
    my $ageGroup = $array[5];
    my $manifestationCategory = $array[7];
    $geneName =~ s/^\s+|\s+$//g;
    $inheritance =~ s/^\s+|\s+$//g;
    $ageGroup =~ s/^\s+|\s+$//g;
    $manifestationCategory =~ s/^\s+|\s+$//g;
    $CGD{ $geneName } = $line; #push gene name as key in hash
    my $annotation = "$inheritance\t$ageGroup\t$manifestationCategory";
    $CGDanno{ $geneName } = $annotation;
}


#Loop over lines in alleleCounts file
open(ACF, "< /groups/umcg-bios/tmp03/projects/outlierGeneASE/pathogenicAlleles/alleleCountPerGroupPerGene.binom.annotated.alleleFiltered.removedCODAMandOutliers.ALL.txt") || die "Can't open file: alleleCountPerGroupPerGene.medianSD3.merged.annotated.depthFiltered.removedCODAM.4outliersRemoved.txt!\n";
open(OUTPUT, "> /groups/umcg-bios/tmp03/projects/outlierGeneASE/pathogenicAlleles/alleleCountPerGroupPerGene.binom.annotated.alleleFiltered.removedCODAMandOutliers.CGD.txt") || die "Can't open file: alleleCountPerGroupPerGene.medianSD3.merged.annotated.depthFiltered.removedCODAM.4outliersRemoved.CGDgenesOnly.txt!\n";

my $acfHeader = `head -1 /groups/umcg-bios/tmp03/projects/outlierGeneASE/pathogenicAlleles/alleleCountPerGroupPerGene.binom.annotated.alleleFiltered.removedCODAMandOutliers.ALL.txt`;
chomp($acfHeader);
print OUTPUT "$acfHeader\tINHERITANCE\tAGEGROUP\tMANIFESTATIONCATEGORY\n";

while (my $line = <ACF>) { #loop over file
    next if $. == 1; #skip header line
    chomp($line);
    my @array = split("\t", $line); #split line
    my $geneName = $array[31]; #extract gene  name
    if (exists $CGD{ $geneName }) { #if gene name exists in CGD hash, output line into new file.
        my $anno = $CGDanno{ $geneName };
        print OUTPUT "$line\t$anno\n";
    }
}
close(OUTPUT);
close(ACF);




