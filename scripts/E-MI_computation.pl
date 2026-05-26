#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($Bin);

if (@ARGV != 3) {
	die "Usage:\nperl $0 <30N|101N> <input.seq> <output_prefix>\n";
}
my $Nlen      = shift;
my $seq_input = shift;
my $output_prefix    = shift;

# ---------- check Nlen ----------
die "Error: Nlen must be 30N or 101N\n" unless ($Nlen eq "30N" || $Nlen eq "101N");

my %noise_pairs;
my %pos_all;
my %num;

my %single;
my %pair;

my (%mi, %mi0);

# ---------- Specific 3-mer combinations that are enriched in negative controls of lig193, or that show enrichment at fixed positions near the center of Widom 601 across different TFs. These combinations were filtered as a blacklist when calculating E-MI for lig193. ----------
if($Nlen eq "30N"){
	my $blacklist = "$Bin/blacklist_30N.list";
	open BLACKLIST, "<", $blacklist or die "Cannot open $blacklist\n";
	while(<BLACKLIST>){
		chomp;
		$noise_pairs{$_} = 1;
	}
	close BLACKLIST;
}

# ---------- parse sequences ----------

my $line = 0;
open IN, "<", $seq_input or die "Cannot open $seq_input\n";

while(<IN>){
	chomp;
	my $len=length($_);
	my $fl_seq;
	if($Nlen eq "30N"){
		next unless($len==147);
		$line++;
		my $seq30N_1=substr($_,0,30);
		my $seq30N_2=substr($_,117,30);
		my $N_seq="N" x 10;
		$fl_seq=$seq30N_1.$N_seq.$seq30N_2;
		$len=70;
	}elsif($Nlen eq "101N"){
		next unless($len>=92 && $len<=109);
		$line++;
		if($len>=101){
			$fl_seq=substr($_,0,101);
		}else{
			my $N_num=101-$len;
			my $N_seq="N" x $N_num;
			$fl_seq=$_.$N_seq;
		}
		$len=101;
	}
	# ---------- single 3-mers ----------
	for(my $k=1;$k<=$len-2;$k++){
		my $seq=substr($fl_seq,$k-1,3);
		$single{$k}{$seq}++;
	}

	# ---------- paired 3-mers ----------
	for(my $i=1;$i<=$len-5;$i++){
		for(my $j=$i+3;$j<=$len-2;$j++){
			my $seq1=substr($fl_seq,$i-1,3);
			my $seq2=substr($fl_seq,$j-1,3);
			my $pos=$i."_".$j;
			$pos_all{$pos}=1;
			next if($seq1=~/N/ || $seq2=~/N/);
			my $kmer=$seq1."_".$seq2;
			$pair{$pos}{$kmer}++;
			$num{$pos}=1;
		}
	}
}
close IN;


# ---------- calculate MI ----------

open OUT,">$output_prefix.MI.out" or die "Cannot write $output_prefix.MI.out\n";
foreach my $pos(keys %pos_all)
{
		print OUT "$pos\t";
		unless(defined($num{$pos})){
			print OUT "NA\tNA\n";
			next;
		}

		%mi=(); %mi0=();
		my @p=split /_/,$pos;
		foreach my $kmer(sort keys %{$pair{$pos}}){
			my @k=split /_/,$kmer;
			my $pos_kmer=$pos."_".$kmer;
			next if($noise_pairs{$pos_kmer});

			my $p3_3=($pair{$pos}{$kmer}+10)/($line+64*64*10);
			my $p3_1=($single{$p[0]}{$k[0]}+10*64)/($line+64*64*10); 
			my $p3_2=($single{$p[1]}{$k[1]}+10*64)/($line+64*64*10);
			
			$mi0{$kmer}=$p3_3/($p3_1*$p3_2);
			
			$mi{$kmer}=$p3_3*log($p3_3/($p3_1*$p3_2))/log(2);
		
		}
		my $top = 0; 
		my $sum_mi = 0;
		my $kmer_list = "";
		foreach my $key(sort{$mi0{$b}<=>$mi0{$a}} keys %mi0){
			$top++;
			last if($top>10);
			$sum_mi+=$mi{$key}; 
			if($top==1){
				$kmer_list=$key;
			}else{
				$kmer_list.=",$key";
			}
		}
		print OUT "$sum_mi\t$kmer_list\n";
}
close OUT; 
