#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my %ENABLE = (do => 1, "don't" => 0);

my $sum = 0;
my $is_enabled = 1;
while (<>) {
    while (/(?:(don't|do)\(\)|mul\((\d{1,3}),(\d{1,3})\))/g) {
        if ($1) {
            $is_enabled = $ENABLE{$1};
        } else {
            $sum += $2 * $3 if $is_enabled;
        }
    }
}
say $sum;

__DATA__
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
