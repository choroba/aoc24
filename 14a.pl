#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;
use List::Util qw{ product };

my ($width, $height) = ARGV::OrDATA::is_using_argv() ? (101, 103) : (11, 7);
my $STEPS = 100;

my @robots;
while (<>) {
    if (/^p=(\d+),(\d+) v=(-?\d+),(-?\d+)/) {
        push @robots, [$1, $2, $3, $4];
    } else {
        die "Can't parse the input line $.: $_";
    }
}

for my $robot (@robots) {
    my ($x, $y, $vx, $vy) = @$robot;
    $y = ($y + $STEPS * $vy) % $height;
    $x = ($x + $STEPS * $vx) % $width;
    @$robot[0, 1] = ($x, $y);
}
my %quadrant;
for my $robot (@robots) {
    my ($x, $y) = @$robot[0, 1];
    my $qx = $x <=> (int($width / 2));
    my $qy = $y <=> (int($height / 2));
    ++$quadrant{"$qx:$qy"};
}

say product(@quadrant{ grep ! /0/, keys %quadrant });

__DATA__
p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3
