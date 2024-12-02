#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my $safe_tally = 0;
while (<>) {
    my @report = split;
    my $is_safe;
    for my $ignore (0 .. $#report) {
        $is_safe = 1;
        my $removed = splice @report, $ignore, 1;
        my $sign = $report[0] <=> $report[1];
        for my $i (1 .. $#report) {
            undef $is_safe if ($report[ $i - 1 ] <=> $report[$i]) != $sign
                           || abs($report[ $i - 1 ] - $report[$i]) > 3;
        }
        splice @report, $ignore, 0, $removed;
        last if $is_safe;
    }
    ++$safe_tally if $is_safe;
}
say $safe_tally;

__DATA__
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
