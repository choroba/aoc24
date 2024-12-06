#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my @DIRS = ([0, -1], [1, 0], [0, 1], [-1, 0]);

my @grid;
my ($x, $y);
while (<>) {
    chomp;
    push @grid, [split //];
    my $pos = index $_, '^';
    ($x, $y) = ($pos, $. - 1) if -1 != $pos;
}
my $direction = 0;

my %visited;
while (1) {
    undef $visited{"$x:$y"};
    my $nx = $x + $DIRS[$direction][0];
    my $ny = $y + $DIRS[$direction][1];
    last if $nx < 0 || $ny < 0 || $ny > $#grid || $nx > $#{ $grid[0] };

    if ('#' eq $grid[$ny][$nx]) {
        $direction = ($direction + 1) % @DIRS;
        redo
    }

    $x = $nx;
    $y = $ny;
}
say scalar keys %visited;



__DATA__
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
