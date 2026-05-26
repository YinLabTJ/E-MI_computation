#!/usr/bin/perl

use strict;
use warnings;

use SVG;
my $svg=SVG->new('width',2400,'height',2400);
my $MI_table=shift;


my @mi;

open IN,"$MI_table" or die "Cannot open $MI_table\n";

my $n=0;

while(<IN>){
	chomp;
	my @t=split;
	next if($t[1] eq "NA");
	$mi[$n]=$t[1];
	$n++;
}
close IN;

my @sorted_mi=sort{$a<=>$b}@mi;
my $int1=int($n*0.005); 
my $div1=$n*0.005-int($n*0.005);
my $white_break=$sorted_mi[$int1-1]*(1-$div1)+$sorted_mi[$int1]*$div1;
my $red_break=$sorted_mi[$n-$int1-1]*$div1+$sorted_mi[$n-$int1]*(1-$div1);

my $blue_break=($white_break+$red_break)/2;

open IN,"$MI_table";
while(<IN>){
	chomp;
	my @t=split;
	my @t2=split /_/,$t[0];
	my $pos1=$t2[0]; 
	my $pos2=$t2[1];
	my $color;

	if($t[1] eq "NA"){
		$color="rgb(180,180,180)";
	}elsif($t[1]>$blue_break){
		my $red=70+185*($t[1]-$blue_break)/($red_break-$blue_break);
		$red=255 if($red>255);
		$red=0 if($red<0);
		my $green=130-($t[1]-$blue_break)/($red_break-$blue_break)*130;
		$green=255 if($green>255);
		$green=0 if($green<0);
		my $blue=180-($t[1]-$blue_break)/($red_break-$blue_break)*180;
		$blue=255 if($blue>255);
		$blue=0 if($blue<0);
		$color="rgb(".$red.",".$green.",".$blue.")";
	}else{
		my $red=70+185*($blue_break-$t[1])/($blue_break-$white_break);
		$red=255 if($red>255);
		$red=0 if($red<0);
		my $green=130+125*($blue_break-$t[1])/($blue_break-$white_break);
		$green=255 if($green>255);
		$green=0 if($green<0);
		my $blue=180+75*($blue_break-$t[1])/($blue_break-$white_break);
		$blue=255 if($blue>255);
		$blue=0 if($blue<0);
		$color="rgb(".$red.",".$green.",".$blue.")";
	}

	my $x=200+($pos2-1)*10+($pos1-1)*10;
	my $y=200+(99-$pos2)*10+($pos1-1)*10;
	my $x1=$x+10; my $x2=$x-10; my $x3=$x;
	my $y1=$y+10; my $y2=$y+10; my $y3=$y+20;
	my $info="$x,$y $x1,$y1 $x3,$y3 $x2,$y2";
	$svg->polygon('points',$info,'style',"fill:$color;stroke:black;stroke-width:0");
}
close IN;

$svg->line('x1',220,'y1',1171,'x2',2140,'y2',1171,'stroke','black','stroke-width',3);
$svg->line('x1',660,'y1',1171,'x2',660,'y2',1178,'stroke','black','stroke-width',3);
$svg->line('x1',1140,'y1',1171,'x2',1140,'y2',1178,'stroke','black','stroke-width',3);
$svg->line('x1',1660,'y1',1171,'x2',1660,'y2',1178,'stroke','black','stroke-width',3);

$svg->text('x',650,'y',1210,'fill','black','stroke','black','-cdata',"25",'font-size',25);
$svg->text('x',1130,'y',1210,'fill','black','stroke','black','-cdata',"50",'font-size',25);
$svg->text('x',1650,'y',1210,'fill','black','stroke','black','-cdata',"75",'font-size',25);

$svg->text('x',210,'y',1150,'fill','black','stroke','black','-cdata',"4",'font-size',25,'transform',"rotate(315, 210, 1150)");
$svg->text('x',1130,'y',210,'fill','black','stroke','black','-cdata',"99",'font-size',25,'transform',"rotate(315, 1130, 210)");
$svg->text('x',1200,'y',200,'fill','black','stroke','black','-cdata',"1",'font-size',25,'transform',"rotate(45, 1200, 200)");
$svg->text('x',2130,'y',1140,'fill','black','stroke','black','-cdata',"96",'font-size',25,'transform',"rotate(45, 2130, 1140)");


my $out=$svg->xmlify;
print $out;
