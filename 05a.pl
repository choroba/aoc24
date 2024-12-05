#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my %order;
my $mode = 1;
my $sum = 0;
while (<>) {
    chomp;
    $mode = 0, next if ! length;

    if ($mode) {
        my ($x, $y) = split /\|/;
        undef $order{$x}{$y};

    } else {
        my @pages = split /,/;
        my $correct = 1;
      PAGE:
        for my $j (1 .. $#pages) {
            for my $i (0 .. $j - 1) {
                $correct = 0, last PAGE
                    if exists $order{ $pages[$j] }{ $pages[$i] };
            }
        }
        if ($correct) {
            $sum += $pages[ @pages / 2 ];
        }
    }
}
say $sum;

__DATA__
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
