#!/usr/bin/perl
#
use strict;
use warnings;
#
use SVG;

my $MI_table=shift;

my $svg=SVG->new('width',2400,'height',2400);
open IN,"$MI_table" or die "Cannot open $MI_table\n";

my @mi;
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
	my $y=200+(68-$pos2)*10+($pos1-1)*10;
	my $x1=$x+10; my $x2=$x-10; my $x3=$x;
	my $y1=$y+10; my $y2=$y+10; my $y3=$y+20;
	my $info="$x,$y $x1,$y1 $x3,$y3 $x2,$y2";
	$svg->polygon('points',$info,'style',"fill:$color;stroke:black;stroke-width:0");
}
close IN;

$svg->line('x1',220,'y1',850,'x2',870,'y2',200,'stroke','black','stroke-width',3);
$svg->line('x1',870,'y1',200,'x2',1520,'y2',850,'stroke','black','stroke-width',3);

$svg->text('x',200,'y',840,'fill','black','stroke','red','-cdata',"4",'font-size',25,'transform',"rotate(315, 200, 840)");
$svg->text('x',440,'y',600,'fill','black','stroke','red','-cdata',"30",'font-size',25,'transform',"rotate(315, 440, 600)");
$svg->text('x',490,'y',590,'fill','black','stroke','red','-cdata',"1",'font-size',25,'transform',"rotate(45, 490, 590)");
$svg->text('x',730,'y',830,'fill','black','stroke','red','-cdata',"27",'font-size',25,'transform',"rotate(45, 730, 830)");

$svg->text('x',1000,'y',840,'fill','black','stroke','blue','-cdata',"4",'font-size',25,'transform',"rotate(315, 1000, 840)");
$svg->text('x',1220,'y',620,'fill','black','stroke','blue','-cdata',"30",'font-size',25,'transform',"rotate(315, 1220, 620)");
$svg->text('x',1290,'y',590,'fill','black','stroke','blue','-cdata',"1",'font-size',25,'transform',"rotate(45, 1290, 590)");
$svg->text('x',1530,'y',830,'fill','black','stroke','blue','-cdata',"27",'font-size',25,'transform',"rotate(45, 1530, 830)");

$svg->text('x',570,'y',470,'fill','black','stroke','blue','-cdata',"1",'font-size',25,'transform',"rotate(315, 570, 470)");
$svg->text('x',820,'y',220,'fill','black','stroke','blue','-cdata',"30",'font-size',25,'transform',"rotate(315, 820, 220)");
$svg->text('x',890,'y',190,'fill','black','stroke','red','-cdata',"1",'font-size',25,'transform',"rotate(45, 890, 190)");
$svg->text('x',1150,'y',450,'fill','black','stroke','red','-cdata',"30",'font-size',25,'transform',"rotate(45, 1150, 450)");

$svg->rect('x',440,'y',950,'width',870,'height',50,'opacity',1,'fill','lightgrey');
$svg->text('x',780,'y',985,'fill','black','stroke','black','-cdata',"87bp 601",'font-size',40);

$svg->rect('x',140,'y',950,'width',300,'height',50,'opacity',1,'fill','red');
$svg->text('x',260,'y',985,'fill','white','stroke','black','-cdata',"30bp",'font-size',40);
$svg->rect('x',1310,'y',950,'width',300,'height',50,'opacity',1,'fill','blue');
$svg->text('x',1430,'y',985,'fill','white','stroke','black','-cdata',"30bp",'font-size',40);

my $out=$svg->xmlify;
print $out;
