#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

my @towels;

sub solve($pattern) {
    _solve($pattern)
}

{   my %cache = ("" => 1);
    sub _solve($pattern) {
        return $cache{$pattern} if exists $cache{$pattern};

        my $count = 0;
        for my $towel (@towels) {
            next unless 0 == index $pattern, $towel;

            $count += _solve(substr $pattern, length $towel);
        }
        return $cache{$pattern} //= $count
    }
}

my $possible = 0;

my $mode = 0;
while (<>) {
    chomp;
    ++$mode, next if "" eq $_;

    if (0 == $mode) {
        @towels = split /, /;
    } else {
        $possible += solve($_);
    }
}

say $possible;

__DATA__
r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb
