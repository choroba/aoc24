#!/usr/bin/perl
use warnings;
use strict;
use experimental qw( signatures );
use feature qw{ say };

use ARGV::OrDATA;
use Time::HiRes qw{ usleep };

my ($width, $height) = ARGV::OrDATA::is_using_argv() ? (101, 103) : (11, 7);

my @robots;
while (<>) {
    if (/^p=(\d+),(\d+) v=(-?\d+),(-?\d+)/) {
        push @robots, [$1, $2, $3, $4];
    } else {
        die "Can't parse the input line $.: $_";
    }
}

# Discover the period and shift by inspecting the robots gathering in
# the vertical middle third and horizontal top half. This might not
# work for other inputs, watch a few iterations to find out.
my $step = 1;
my $x3 = int(($width  + 1) / 3);
my $y2 = int(($height + 1) / 2);
my ($shift, $period) = (1, 1);
while (1) {
    my @xthirds;
    my @yhalves;
    for my $robot (@robots) {
        my ($x, $y, $vx, $vy) = @$robot;
        $y = ($y + $period * $vy) % $height;
        $x = ($x + $period * $vx) % $width;
        @$robot[0, 1] = ($x, $y);
        ++$xthirds[ int($x / $x3) ];
        ++$yhalves[ int($y / $y2) ] if 1 < $period;
    }
    last if 1 < $period && $yhalves[0] > $yhalves[1] * 2;
    if (1 == $period && $xthirds[1] > $xthirds[0] + $xthirds[2]) {
        if (1 == $shift) {
            $shift = $step;
        } elsif (1 == $period) {
            $period = $step - $shift;
        }
    }
    $step += $period;
}

my @grid;
++$grid[ $_->[1] ][ $_->[0] ] for @robots;
for my $row (@grid) {
    say map $_ ? 'x' : ' ', @$row;
}

say "$period, $shift\n$step";

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
