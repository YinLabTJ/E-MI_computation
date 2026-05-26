#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($Bin);

# ---------- usage ----------
if (@ARGV != 3) {

    die "Usage:\n".
        "perl $0 <30N|101N> <input.seq> <output_prefix>\n";
}

my $Nlen      = shift;
my $seq_input = shift;
my $output    = shift;

# ---------- check mode ----------
die "Error: Nlen must be 30N or 101N\n"
    unless ($Nlen eq "30N" || $Nlen eq "101N");

# ---------- run E-MI computation ----------
my $cmd1 =
    "perl $Bin/scripts/E-MI_computation.pl ".
    "$Nlen $seq_input $output";

system($cmd1) == 0
    or die "Failed: $cmd1\n";

# ---------- run heatmap ----------
my $cmd2;

if ($Nlen eq "101N") {

    $cmd2 =
        "perl $Bin/scripts/heatmap.101N.pl ".
        "$output.MI.out > $output.svg";

} elsif ($Nlen eq "30N") {

    $cmd2 =
        "perl $Bin/scripts/heatmap.30N.pl ".
        "$output.MI.out > $output.svg";
}

system($cmd2) == 0
    or die "Failed: $cmd2\n";
