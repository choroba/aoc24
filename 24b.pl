#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;
use List::Util qw{ min shuffle };
use Storable qw{ dclone };

my %g;
my %r;
while (<>) {
    if (/^(\w+) (AND|OR|XOR) (\w+) -> (\w+)/) {
        my ($arg1, $op, $arg2, $r) = @{^CAPTURE};
        undef $g{$r}{$op}{$_} for $arg1, $arg2;
        $g{$_} //= undef for $arg1, $arg2;
        undef $r{$_}{$op}{$r} for $arg1, $arg2;
    }
}

sub count_errors($g, $r) {
    my %err;
    my @z = sort grep /^z/, keys %$g;
    my $max = substr $z[-1], 1;
    for my $z (@z[ 0 .. $#z - 1]) {
        $err{$z} |= 1 if ! exists $g->{$z}{XOR};
        $err{$z} |= 2 if $r->{$z};
        my $id = substr $z, 1;
        if ($g->{$z}{XOR}) {
            my @args = keys %{ $g->{$z}{XOR} };

            if ('00' ne $id) {
                if(grep /^[xy]/, @args) {
                    $err{$z} |= 4;
                } elsif ('01' ne $id) {
                    my @xor = grep exists $g->{$_}{XOR}, @args;
                    my @or  = grep exists $g->{$_}{OR},  @args;
                    $err{$z} |=  8 if 1 != @or;
                    $err{$z} |= 16 if 1 != @xor;
                    for my $arg (@args) {
                        if (my @xy = sort keys %{ $g->{$arg}{XOR} // {} }) {
                            $err{$arg} |= 32
                                if "@xy" ne "x$id y$id";
                        }
                    }
                }
            }
        }
    }
    for my $n (grep /^[^xyz]/, keys %$g) {
        if ($g->{$n}{AND}) {
            $err{$n} |= 64
                if ! exists $r->{$n}{OR} || 1 < keys %{ $r->{$n} };

        } elsif ($g->{$n}{OR} || $g->{$n}{XOR}) {
            $err{$n} |= 128 if ! exists $r->{$n}{AND}
                            || ! exists $r->{$n}{XOR}
                            || exists $r->{$n}{OR};
            if ($g->{$n}{XOR}) {
                $err{$n} |= 256 if grep /^[^z]/, keys %{ $r->{$n}{XOR} };
            }
        }
    }
    for my $x (grep /^x/, keys %$g) {
        my $id = substr $x, 1;
        my @xxor      =     keys %{ $r->{$x}{XOR} };
        my @xand      =     keys %{ $r->{$x}{AND} };
        my @xxorxor   = map keys %{ $r->{$_}{XOR} }, @xxor;
        my @xxorand   = map keys %{ $r->{$_}{AND} }, @xxor;
        my @xxorandor = map keys %{ $r->{$_}{OR} }, @xxorand;
        my @xandor    = map keys %{ $r->{$_}{OR} }, @xand;
        my @xandorxor = map keys %{ $r->{$_}{XOR} }, @xandor;

        $err{$x} |=  512 if @xxorxor != 1 || $xxorxor[0] ne "z$id";
        $err{$x} |= 1024 if 1 != @xxorandor
                         || 1 != @xandor
                         || $xxorandor[0] ne $xandor[0];
        $err{$x} |= 2048 if $id != $max - 1
                         && (@xandorxor != 1
                             || $xandorxor[0] ne 'z'
                                                 . sprintf '%02d', $id + 1);

        my $y = "y$id";
        my @yxor    =     keys %{ $r->{$y}{XOR} };
        my @yxorxor = map keys %{ $r->{$_}{XOR} }, @yxor;
        $err{$y} |= 512 if @yxorxor != 1 || $yxorxor[0] ne "z$id";
    }
    my $errors = 0;
    $errors += unpack '%32b*', pack 'S', $_ for values %err;
    return $errors
}

sub generate(@c) {
    my $g = dclone \%g;
    my $r = dclone \%r;
    for my $i (0 .. (@c - 2) / 2) {
        for my $rr (@c[ 2 * $i, 2 * $i + 1 ]) {
            for my $op (keys %{ $g->{$rr} }) {
                for my $arg (keys %{ $g->{$rr}{$op} }) {
                    delete $r->{$arg}{$op}{$rr};
                    delete $r->{$arg}{$op} unless keys %{ $r->{$arg}{$op} };
                    delete $r->{$arg}      unless keys %{ $r->{$arg} };
                }
            }
        }

        @$g{ @c[ 2 * $i, 1 + 2 * $i ] } = @$g{ @c[ 1 + 2 * $i, 2 * $i ] };

        for my $rr (@c[ 2 * $i, 2 * $i + 1 ]) {
            for my $op (keys %{ $g->{$rr} }) {
                for my $arg (keys %{ $g->{$rr}{$op} }) {
                    undef $r->{$arg}{$op}{$rr};
                }
            }
        }
    }
    return $g, $r
}

sub normalise(@c) {
    my %pairs = @c;
    $pairs{ delete $pairs{$_} } = $_ for grep $_ gt $pairs{$_}, keys %pairs;
    my @sorted_first = sort keys %pairs;
    my $c = [map +($_, $pairs{$_}), @sorted_first];
    return $c
}

my @g = grep /^[^xy]/, keys %g;

my @cs = map normalise((shuffle(@g))[0 .. 7]), 1 .. 100;
my @population = map [generate(@$_)], @cs;
my @scores = map count_errors(@$_), @population;

my $min = 'Inf';
while ($min > 5) {
    my @next;
    for my $i (0 .. $#population) {
        for (1 .. @population < 10 ? 20 - @population : 2) {
            my $rnd;
            do {
                $rnd = $g[rand @g]
            } while grep $_ eq $rnd, @{ $cs[$i] };
            my $idx = int rand 8;
            my $new_c = [ @{ $cs[$i] } ];
            $new_c->[$idx] = $rnd;
            $new_c = normalise(@$new_c);
            my $new_pop = [generate(@$new_c)];
            my $new_score = count_errors(@$new_pop);
            if ($new_score <= $scores[$i]) {
                push @next, [$new_c, $new_pop, $new_score];
            }
        }
    }

    my $threshold = (sort { $a <=> $b } @scores)[@scores / 2.1];
    --$threshold if @population > 500;
    say "Th: $threshold";
    for my $i (reverse 0 .. $#scores) {
        if ($scores[$i] > $threshold && int rand @population) {
            splice @scores, $i, 1;
            splice @cs, $i, 1;
            splice @population, $i, 1;
        }
    }
    push @cs, map $_->[0], @next;
    push @population, map $_->[1], @next;
    push @scores, map $_->[2], @next;

    # Remove duplicates.
    my %dup;
    for my $i (reverse 0 .. $#cs) {
        my $srl = "@{ $cs[$i] }";
        if ($dup{$srl}++) {
            splice @scores, $i, 1;
            splice @cs, $i, 1;
            splice @population, $i, 1;
        }
    }

    if (@population <= 2) {
        unshift @cs, map [(shuffle(@g))[0 .. 7]], 0 .. 24;
        unshift @population, map [generate(@$_)], @cs[0 .. 24];
        unshift @scores, map count_errors(@$_), @population[0 .. 24];

    }

    $min = min(@scores);
    my @best = grep $scores[$_] == $min, 0 .. $#scores;
    say join ', ', map "@$_", @cs[@best];
    say "Pop: ", scalar @population;
    say 'Min: ', $min;
}
$min = min(@scores);
my @best = grep $scores[$_] == $min, 0 .. $#scores;
say join ',', sort @{ @cs[ $best[0] ] };
