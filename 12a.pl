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

my %area;
my %perimeter;
for my $y (0 .. $#grid) {
    for my $x (0 .. $#{ $grid[0] }) {
        ++$area{ $grid[$y][$x] };
        for my $dir (@DIRS) {
            my $ny = $y + $dir->[0];
            my $nx = $x + $dir->[1];
            ++$perimeter{ $grid[$y][$x] }
                if $ny < 0 || $nx < 0
                || $ny > $#grid || $nx > $#{ $grid[0] }
                || $grid[$ny][$nx] != $grid[$y][$x];
        }
    }
}

my $price = 0;
for my $region (keys %area) {
    $price += $area{$region} * $perimeter{$region};
}
say $price;

__DATA__
AAAA
BBCD
BBCC
EEEC
