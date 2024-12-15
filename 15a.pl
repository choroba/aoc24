#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

my %DIR = ( '^' => [0, -1],
            '>' => [1, 0],
            'v' => [0, 1],
            '<' => [-1, 0]);
my @grid;
my @moves;
my ($x, $y);
my $mode = 0;
while (<>) {
    chomp;
    $mode = 1, next if "" eq $_;

    if (0 == $mode) {
        push @grid, [split //];
        if (/@/g) {
            $y = ($. - 1);
            $x = pos($_) - 1;
            $grid[$y][$x] = '.';
        }
    } else {
        push @moves, split //;
    }
}

sub move($xr, $yr, $nx, $ny, $) {
    $$xr = $nx;
    $$yr = $ny;
}

sub Push($xr, $yr, $nx, $ny, $dir) {
    my $last_x = $nx;
    my $last_y = $ny;
    while ('O' eq $grid[$last_y][$last_x]) {
        $last_x += $dir->[0];
        $last_y += $dir->[1];
    }
    return if '#' eq $grid[$last_y][$last_x];

    $grid[$last_y][$last_x] = 'O';
    $$xr = $nx;
    $$yr = $ny;
}

my %DISPATCH = (
    '#' => undef,
    'O' => \&Push,
    '.' => \&move
);

for my $move (@moves) {
    my $dir = $DIR{$move};
    my $nx = $x + $dir->[0];
    my $ny = $y + $dir->[1];
    my $what = $grid[$ny][$nx];
    $DISPATCH{$what}->(\$x, \$y, $nx, $ny, $dir) if defined $DISPATCH{$what};
    $grid[$y][$x] = '.';
}

my $gps = 0;
for my $y (0 .. $#grid) {
    for my $x (0 .. $#{ $grid[0] }) {
        $gps += 100 * $y + $x if 'O' eq $grid[$y][$x];
    }
}

say $gps;

__DATA__
########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

<^^>>>vv<v>>v<<
