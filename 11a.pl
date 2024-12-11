#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my $STEP_COUNT = 25;

my @stones = split ' ', <>;

for (1 .. $STEP_COUNT) {
    my $shift = 0;
    for my $j (0 .. $#stones) {
        my $i = $j + $shift;
        if ($stones[$i] == 0) {
            $stones[$i] = 1;
        } elsif (0 == length($stones[$i]) % 2) {
            my $new_length = length($stones[$i]) / 2;
            splice @stones, $i, 1,
                   map 0 + $_,
                   $stones[$i] =~ /^(.{$new_length})(.{$new_length})$/;
            ++$shift;
        } else {
            $stones[$i] *= 2024;
        }
    }
}

say scalar @stones;

__DATA__
125 17
