#!/usr/bin/perl
use warnings;
use strict;
use experimental qw( signatures );
use feature qw{ say };

use ARGV::OrDATA;
use List::Util qw{ min };

my $TA = 3;
my $TB = 1;

sub win($ax, $ay, $bx, $by, $px, $py) {
    my $ra = ($py * $bx - $px * $by) / ($bx * $ay - $ax * $by);
    return 0 if $ra != int $ra;

    my $rb = ($px - $ax * $ra) / $bx;
    return 0 if $rb != int $rb;

    return $ra * $TA + $rb * $TB
}

my $tokens = 0;
while (<>) {
    my ($ax, $ay) = /^Button A: X(\+\d+), Y(\+\d+)/;
    $_ = <>;
    my ($bx, $by) = /^Button B: X(\+\d+), Y(\+\d+)/;
    $_ = <>;
    my ($px, $py) = /^Prize: X=(\d+), Y=(\d+)/;

    $_ += 10000000000000 for $px, $py;

    my $win = win($ax, $ay, $bx, $by, $px, $py);
    $tokens += $win if $win ne 'Inf';

    <> or last;
}

say $tokens;

__DATA__
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
