#!/usr/bin/perl
use warnings;
use strict;
use experimental qw( signatures );
use feature qw{ say };

use ARGV::OrDATA;

my $HEIGHT = 7;
my $WIDTH  = 5;

{   my %DISPATCH = (LOCK => sub($h, $x, $y) { $h->[$x] = $y },
                    KEY  => sub($h, $x, $y) { ++$h->[$x] });
    sub process($inventory, $lines) {
        my $what = '.' eq $lines->[0][0] ? 'KEY' : 'LOCK';
        my @heights;
        for my $y (0 .. $HEIGHT - 1) {
            for my $x (0 .. $WIDTH - 1) {
                $DISPATCH{$what}->(\@heights, $x, $y)
                    if '#' eq $lines->[$y][$x];
            }
        }
        if ('KEY' eq $what) {
            --$_ for @heights;
        }
        push @{ $inventory->{$what} }, \@heights;
    }
}

my %inventory;
my @current;
while (my $line = <>) {
    chomp $line;
    if ($line) {
        push @current, [split //, $line];
    } else {
        if (@current) {
            process(\%inventory, \@current);
            @current = ()
        }
    }
}
process(\%inventory, \@current);

my $fit_tally = 0;
for my $lock (@{ $inventory{LOCK} }) {
  KEY:
    for my $key (@{ $inventory{KEY} }) {
        for my $x (0 .. $WIDTH - 1) {
            next KEY if $lock->[$x] + $key->[$x] >= $HEIGHT - 1;
        }
        ++$fit_tally;
    }
}

say $fit_tally;

__DATA__
#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####
