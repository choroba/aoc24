#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;
use List::Util qw{ sum };

my @lists;
while (<>) {
    my ($x, $y) = split;
    push @{ $lists[0] }, $x;
    push @{ $lists[1] }, $y;
}

@$_ = sort { $a <=> $b } @$_ for @lists;
say sum(map abs($lists[0][$_] - $lists[1][$_]), 0 .. $#{ $lists[0] });

__DATA__
3   4
4   3
2   5
1   3
3   9
3   3
