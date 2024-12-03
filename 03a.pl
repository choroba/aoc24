#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my $sum = 0;
while (<>) {
    while (/mul\((\d{1,3}),(\d{1,3})\)/g) {
        $sum += $1 * $2;
    }
}
say $sum;

__DATA__
xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
