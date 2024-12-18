#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my @DIRS = ([0, 1], [1, 0], [-1, 0], [0, -1]);

my $size = ARGV::OrDATA::is_using_data() ?  6 :   70;
my $time = ARGV::OrDATA::is_using_data() ? 12 : 1024;

my @grid;
while (<>) {
    chomp;
    my ($x, $y) = split /,/;
    $grid[$y][$x] = $.;
}

my %path;
my %agenda = (pack('CC', 0, 0) => undef);

my $length = 0;
my %next;
while (! exists $path{ pack 'CC', $size, $size }) {
    for my $coord (keys %agenda) {
        undef $path{$coord};
        my ($x, $y) = unpack 'CC', $coord;
        for my $dir (@DIRS) {
            my $nx = $x + $dir->[0];
            my $ny = $y + $dir->[1];
            next if $nx < 0 || $ny < 0 || $ny > $size || $nx > $size
                 || ($grid[$ny][$nx] // 1 + $time) <= $time;

            undef $next{ pack 'CC', $nx, $ny };
        }
    }
} continue {
    %agenda = %next;
    %next = ();
    ++$length;
}

say $length - 1;

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
