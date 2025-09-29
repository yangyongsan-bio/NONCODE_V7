#!/sur/bin/perl -w

die "perl $0 rowname labels Cluster.xls\n\n" unless(@ARGV == 3);
my %label;
my $ha;
my %type;
open IN1,"$ARGV[0]"; <IN1>;#rowname
open IN2,"$ARGV[1]"; <IN2>;#labels
while(<IN1>){
	chomp;
	my @a=split /\t/,$_;
	chomp(my $l=<IN2>);
	my @b=split /\t/,$l;
	$label{$a[1]}=$b[1];
}
close IN1;close IN2;
open IN,"$ARGV[2]/2.Cluster/Cluster.xls";<IN>; #Cluster.xls
while(<IN>){
	chomp;
	my @a=split /\t/,$_;
	$ha{$a[1]}{$label{$a[0]}}++;
}
close IN;
print "Cluster\tCellType\n";
my $str='';
my $str2='';
foreach my $c(sort { $a <=> $b } keys %ha){
	my ($score,$celltype);
	foreach my $t(keys $ha{$c}){
		if($score){
			if($ha{$c}{$t} > $score){
				$score=$ha{$c}{$t};
				$celltype=$t;
			}
		}else{
			$score=$ha{$c}{$t};
			$celltype=$t;
		}
	}
	print "$c\t$celltype\n";
	$str=$str."\"$celltype\",";
	$str2=$str2."\"$c\",";
}
$str=~s/,$//;
$str2=~s/,$//;
chomp(my $sample=`basename $ARGV[2]`);
my $sample1=$sample;
$sample=~s/-/_/g;
my ($exp,$rds);
if(-d "$ARGV[2]/1.QC"){
        $rds="data_$sample<-readRDS(\"$ARGV[2]/data_$sample.rds\")";
}elsif(-f "$ARGV[2]/$sample.combined.rds"){
        $rds="data_$sample<-readRDS('$ARGV[2]/$sample.combined.rds')";
}
open OUT,">replot.R";
print OUT <<CODE;
library(Seurat)
#$rds
#new.cluster.ids <- c($str)
#names(new.cluster.ids) <- levels(data_$sample)
#data_$sample <- RenameIdents(data_$sample, new.cluster.ids)
#pdf(file="$sample\_CellType_umap.pdf")
#DimPlot(data_$sample, reduction = "umap", label = TRUE, pt.size = 0.5) + NoLegend()
#dev.off()
#pdf(file="$sample\_CellType_tsne.pdf")
#DimPlot(data_$sample, reduction = "tsne", label = TRUE, pt.size = 0.5) + NoLegend()
#dev.off()

CODE
