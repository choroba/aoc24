#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

my %gate;

my %DISPATCH = (
    AND => sub($i, $j) { (0 + $i) & (0 + $j) },
    OR  => sub($i, $j) { (0 + $i) | (0 + $j) },
    XOR => sub($i, $j) { (0 + $i) ^ (0 + $j) },
);

while (my $line = <>) {
    if ($line =~ /^(\w+): ([01])$/) {
        die $_ if exists $gate{$1};

        $gate{$1}{value} = $2;

    } elsif ($line =~ /^(\w+) (AND|OR|XOR) (\w+) -> (\w+)$/) {
        my ($arg1, $op, $arg2, $result) = @{^CAPTURE};
        die $_ if exists $gate{$result};

        $gate{$result}{$op} = [$arg1, $arg2];
    }
}

my $change = 1;
while ($change) {
    undef $change;
    for my $g (keys %gate) {
        next if exists $gate{$g}{value};

        my $op = (keys %{ $gate{$g} })[0];
        my @args = @{ $gate{$g}{$op} };
        next unless exists $gate{ $args[0] }{value}
                 && exists $gate{ $args[1] }{value};

        $gate{$g}{value} = 0 + $DISPATCH{$op}(map $gate{$_}{value}, @args);
        delete $gate{$g}{$op};
        $change = 1;
    }
}

my $out = "";
for my $o (sort grep 0 == index($_, 'z'), keys %gate) {
    $out .= $gate{$o}{value};
}

my $result = 0;
my $p = 1;

for my $d (split //, $out) {
    $result += $d * $p;
    $p *= 2;
}

say $result;

__DATA__
x00: 1
x01: 1
x02: 1
y00: 0
y01: 1
y02: 0

x00 AND y00 -> z00
x01 XOR y01 -> z01
x02 OR y02 -> z02
