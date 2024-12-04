#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my $xmas_tally = 0;
my @grid;
while (<>) {
    chomp;
    push @grid, [split //];
}

my $h = $#grid;
my $w = $#{ $grid[0] };


my %X = (M => 'S', S => 'M');
for my $y (1 .. $h - 1) {
    for my $x (1 .. $w - 1) {
        next unless 'A' eq $grid[$y][$x];

        my $g00 = $grid[$y - 1][$x - 1];
        my $g01 = $grid[$y - 1][$x + 1];
        my $g10 = $grid[$y + 1][$x - 1];
        my $g11 = $grid[$y + 1][$x + 1];
        ++$xmas_tally if $g00 =~ /[MS]/ && $g11 eq $X{$g00}
                      && $g01 =~ /[MS]/ && $g10 eq $X{$g01};
    }
}

say $xmas_tally;


__DATA__
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
