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
    $xmas_tally += () = /XMAS/g;
    $xmas_tally += () = /SAMX/g;
}

my $h = $#grid;
my $w = $#{ $grid[0] };

for my $x (0 .. $w) {
    my $s = join "", map $grid[$_][$x], 0 .. $h;
    $xmas_tally += () = $s =~ /XMAS/g;
    $xmas_tally += () = $s =~ /SAMX/g;
}

for my $y (-$w - $h .. $h + $w) {
    my $d = "";  # /
    my $e = "";  # \
    for my $x (-$w - $h .. $h + $w) {

        $d .= $grid[$y + $x][$x] // "" unless $x < 0 || $y + $x < 0;
        $e .= $grid[$y + $x][$w - $x] // "" unless $w - $x < 0 || $y + $x < 0;
    }
    $xmas_tally += () = $d =~ /XMAS/g;
    $xmas_tally += () = $d =~ /SAMX/g;
    $xmas_tally += () = $e =~ /XMAS/g;
    $xmas_tally += () = $e =~ /SAMX/g;
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
