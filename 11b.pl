#!/usr/bin/perl
use warnings;
use strict;
use experimental qw( signatures );
use feature qw{ say };

use ARGV::OrDATA;
use List::Util qw{ sum };

my $STEP_COUNT = 75;

sub change($n) {
    if ($n == 0) {
        return 1

    } elsif (0 == length($n) % 2) {
        my $new_length = length($n) / 2;
        return map 0 + $_,
            substr($n, 0, $new_length),
            substr($n, $new_length, $new_length)

    } else {
        return $n * 2024
    }
}

my @stones = split ' ', <>;
my %stone;
++$stone{$_} for @stones;

for (1 .. $STEP_COUNT) {

    my %next;
    for my $stone (keys %stone) {
        $next{$_} += $stone{$stone} for change($stone);
    }
    %stone = %next;
}

say sum(values %stone);

__DATA__
125 17
