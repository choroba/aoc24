#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

my @towels;
my $towel_r;

sub solve($pattern) {
    return $pattern =~ /^(?:$towel_r)+$/
}

my $possible = 0;

my $mode = 0;
while (<>) {
    chomp;
    ++$mode, next if "" eq $_;

    if (0 == $mode) {
        @towels = split /, /;
        $towel_r = join '|', @towels;
    } else {
        ++$possible if solve($_);
    }
}

say $possible;

__DATA__
r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb
