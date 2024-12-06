#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my @DIRS = ([0, -1], [1, 0], [0, 1], [-1, 0]);

my @grid;
my ($sx, $sy);
while (<>) {
    chomp;
    push @grid, [split //];
    my $pos = index $_, '^';
    ($sx, $sy) = ($pos, $. - 1) if -1 != $pos;
}

sub walk {
    my ($x, $y) = ($sx, $sy);
    my %visited;
    my $direction = 0;
    while (1) {
        return 'loop' if exists $visited{"$x:$y:$direction"};

        undef $visited{"$x:$y:$direction"};
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
    return \%visited
}

my %path = %{ walk() };
for my $xyd (keys %path) {
    delete $path{$xyd};
    my $xy = $xyd =~ s/:[0123]$//r;
    undef $path{$xy};
}
delete $path{"$sx:$sy"};

my $loop_tally = 0;
for my $pos (keys %path) {
    my ($ox, $oy) = split /:/, $pos;
    local $grid[$oy][$ox] = '#';

    ++$loop_tally if 'loop' eq walk();
}

say $loop_tally;

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
