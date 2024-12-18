#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my @DIRS = ([0, 1], [1, 0], [-1, 0], [0, -1]);

my $size       = ARGV::OrDATA::is_using_data() ?  6 :   70;
my $start_time = ARGV::OrDATA::is_using_data() ? 12 : 1024;

my @grid;
while (<>) {
    chomp;
    my ($x, $y) = split /,/;
    $grid[$y][$x] = $.;
}

my $time = $start_time + 1;
while (1) {
    my %path;
    my %agenda = (pack('SS', 0, 0) => undef);

    my %next;
    while (! exists $path{ pack 'SS', $size, $size } && keys %agenda) {
        for my $coord (keys %agenda) {
            undef $path{$coord};
            my ($x, $y) = unpack 'SS', $coord;
            for my $dir (@DIRS) {
                my $nx = $x + $dir->[0];
                my $ny = $y + $dir->[1];
                my $ncoord = pack 'SS', $nx, $ny;
                next if $nx < 0 || $ny < 0 || $ny > $size || $nx > $size
                     || exists $path{$ncoord}
                     || ($grid[$ny][$nx] // 1 + $time) <= $time;

                undef $next{$ncoord};
            }
        }
    } continue {
        %agenda = %next;
        %next = ();
    }
    last if ! exists $path{ pack 'SS', $size, $size };

    ++$time
}

for my $y (0 .. $size) {
    for my $x (0 .. $size) {
        say("$x,$y"), exit if ($grid[$y][$x] // 0) == $time;
    }
}


__DATA__
5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0
