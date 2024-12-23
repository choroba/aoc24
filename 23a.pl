#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

my %g;
while (my $line = <>) {
    chomp $line;
    my (@c) = split /-/, $line;
    undef $g{ $c[0] }{ $c[1] };
    undef $g{ $c[1] }{ $c[0] };
}

my %found;
for my $c0 (keys %g) {
    next if $c0 !~ /^t/;

    for my $c1 (keys %{ $g{$c0} }) {
        next if $c0 eq $c1;

        for my $c2 (keys %{ $g{$c1} }) {
            undef $found{ join '-', sort $c0, $c1, $c2 }
                if exists $g{$c0}{$c2};
        }
    }
}

say scalar keys %found;

__DATA__
kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn
