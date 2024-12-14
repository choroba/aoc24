#!/usr/bin/perl
use warnings;
use strict;
use experimental qw( signatures );
use feature qw{ say };

use ARGV::OrDATA;
use Time::HiRes qw{ usleep };

sub move_to($x, $y) {
    ++$y; ++$x;
    print "\e[$y;${x}H"
}

sub clear() {
    print "\e[2J";
    move_to(0, 0);
}

my ($width, $height) = ARGV::OrDATA::is_using_argv() ? (101, 103) : (11, 7);

my @robots;
while (<>) {
    if (/^p=(\d+),(\d+) v=(-?\d+),(-?\d+)/) {
        push @robots, [$1, $2, $3, $4];
    } else {
        die "Can't parse the input line $.: $_";
    }
}

clear();
for my $y (1 .. $height) {
    for my $x (1 .. $width) {
        print '.';
    }
    print "\n";
}

my $step = 1; # 72, 173
for (1 .. 7344) {
    for my $robot (@robots) {
        my ($x, $y, $vx, $vy) = @$robot;
        move_to($x, $y);
        $y = ($y + $vy) % $height;
        $x = ($x + $vx) % $width;
        print ' ';
        @$robot[0, 1] = ($x, $y);
        move_to($x, $y);
        print 'x'
    }
    move_to(0, $height);
    say $step++;
    # usleep(500000) if $step++ == 7344;
}


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
