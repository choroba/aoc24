#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my @grid;
my @trailheads;
while (<>) {
    chomp;
    push @grid, [split //];
    push @trailheads, [pos($_) - 1, $. - 1] while /0/g;
}

my @DIRS = ([0, 1], [1, 0], [0, -1], [-1, 0]);
my $sum = 0;
for my $trailhead (@trailheads) {
    my $score = 0;
    my %agenda = ("@$trailhead" => undef);
    my %next;
    while (keys %agenda) {
        my $coord = (keys %agenda)[0];
        delete $agenda{$coord};
        my ($x, $y) = split / /, $coord;
        ++$score, next if 9 == $grid[$y][$x];

        for my $dir (@DIRS) {
            my $nx = $x + $dir->[0];
            my $ny = $y + $dir->[1];
            next if $nx < 0 || $ny < 0 || $ny > $#grid || $nx > $#{ $grid[0] }
                 || $grid[$ny][$nx] != 1 + $grid[$y][$x];

            undef $next{"$nx $ny"};
        }
        %agenda = %next, %next = () unless keys %agenda;
    }
    $sum += $score;
}

say $sum;

__DATA__
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
