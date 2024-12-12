#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

my @DIRS = ([0, 1], [1, 0], [-1, 0], [0, -1]);

my @grid;
while (<>) {
    chomp;
    push @grid, [split //];
}

sub fill($y, $x, $char, $region, $depth) {
    $grid[$y][$x] = $region;
    for my $dir (@DIRS) {
        my $ny = $y + $dir->[0];
        my $nx = $x + $dir->[1];
        next if $ny < 0 || $nx < 0 || $ny > $#grid || $nx > $#{ $grid[0] };

        no warnings 'recursion';
        fill($ny, $nx, $char, $region, $depth + 1)
            if $grid[$ny][$nx] eq $char;
    }
}

my $region = 1;
for my $y (0 .. $#grid) {
    for my $x (0 .. $#{ $grid[0] }) {
        if ($grid[$y][$x] =~ /[A-Z]/) {
            fill($y, $x, $grid[$y][$x], $region, 0);
            ++$region;
        }
    }
}

for my $row (@grid) {
    unshift @$row, 0;
    push @$row, 0
}
unshift @grid, [(0) x @{ $grid[0] }];
push    @grid, [(0) x @{ $grid[0] }];


my @CHECKS = ([0, 1, -1, 0],  # Top
              [0, 1, 1, 0],   # Bottom
              [1, 0, 0, -1],  # Left
              [1, 0, 0, 1]);  # Right
my %area;
my %sides;
for my $y (0 .. $#grid) {
    for my $x (0 .. $#{ $grid[0] }) {
        next unless $grid[$y][$x];

        ++$area{ $grid[$y][$x] };
        for my $check (@CHECKS) {
            my $n0y = $y + $check->[0];
            my $n0x = $x + $check->[1];

            my $n1y = $y + $check->[2];
            my $n1x = $x + $check->[3];

            my $dy = $n0y + $check->[2];
            my $dx = $n0x + $check->[3];

            ++$sides{ $grid[$y][$x] }
                if $grid[$n1y][$n1x] != $grid[$y][$x]
                && ($grid[$n0y][$n0x] != $grid[$y][$x]
                    || $grid[$dy][$dx] == $grid[$y][$x]);
        }
    }
}

my $price = 0;
for my $region (keys %area) {
    $price += $area{$region} * $sides{$region};
}

say $price;

__DATA__
AAAA
BBCD
BBCC
EEEC
