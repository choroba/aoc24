#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my %antenna;
my ($height, $width);
while (<>) {
    chomp;
    $height = $. - 1;
    $width = length($_) - 1;
    while (/([^.])/g) {
        my $x = pos($_) - 1;
        push @{ $antenna{$1} }, [$x, $height];
    }
}

my %antinode;
for my $type (keys %antenna) {
    for my $i (1 .. $#{ $antenna{$type} }) {
        my ($x1, $y1) = @{ $antenna{$type}[$i] };
        for my $j (0 .. $i - 1) {
            my ($x2, $y2) = @{ $antenna{$type}[$j] };
            my @vectors = map [$_ * ($x1 - $x2), $_ * ($y1 - $y2)], 1, -1;
            for my $idx (0, 1) {
                my $vector = $vectors[$idx];
                my $size = 0;
              SIZE: while (1) {
                    my $anx = ($x1, $x2)[$idx] + $size * $vector->[0];
                    last if $anx < 0 || $anx > $width;

                    my $any = ($y1, $y2)[$idx] + $size * $vector->[1];
                    last if $any < 0 || $any > $height;

                    undef $antinode{"$anx:$any"};
                } continue {
                    ++$size;
                }
            }
        }
    }
}

say scalar keys %antinode;

__DATA__
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
