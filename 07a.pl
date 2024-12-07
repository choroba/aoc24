#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my %FLIP = ('+' => '*', '*' => '+');

my %CALC = ('+' => sub { $_[0] + $_[1] },
            '*' => sub { $_[0] * $_[1] });

my $sum = 0;
EQUATION:
while (<>) {
    chomp;
    my ($expected, $numbers) = split /: /;

    my @operators = ('+') x ($numbers =~ tr/ //);
    my $size = @operators;
    while (@operators == $size) {
        my $formula = $numbers;
        my $i = 0;
        $formula =~ s/ /$operators[$i++]/g;
        my $result = $formula;
        1 while $result =~ s/(^\d+)([+*])(\d+)/$CALC{$2}($1, $3)/e;

        $sum += $result, next EQUATION if $expected == $result;

        my $j = $#operators;
        while (1) {
            $operators[$j] = $FLIP{ $operators[$j] };
            last if '*' eq $operators[$j];
            last if --$j < 0;
        }
        splice @operators, 0, 0, '+' if $j < 0;
    }
}
say $sum;

__DATA__
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
