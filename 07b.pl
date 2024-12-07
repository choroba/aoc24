#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

sub add  { $_[0] + $_[1] }
sub mult { $_[0] * $_[1] }
sub cnct { $_[0] . $_[1] }

my %FLIP = ('+' => '.', '.' => '*', '*' => '+');

my %CALC = ('+' => \&add,
            '*' => \&mult,
            '.' => \&cnct);

my $sum = 0;
EQUATION:
while (<>) {
    chomp;
    my ($expected, @numbers) = split /: | /;

    my @operators = ('+') x (@numbers - 1);
    my $size = @operators;
    while (1) {
        my @n = @numbers;
        my @o = @operators;
        unshift @n, $CALC{ shift @o }(splice @n, 0, 2)
            while $n[0] <= $expected && @o;

        $sum += $expected, next EQUATION if $expected == $n[0];

        my $j = $#operators;
        while (1) {
            $operators[$j] = $FLIP{ $operators[$j] };
            last if '+' ne $operators[$j];
            last if --$j < 0;
        }
        last if $j < 0;
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
