#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

my %COLOR = (x => 'blue', y => 'green', z => 'magenta');

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

my %err;
@err{ keys %g } = (0) x keys %g;

my @z = sort grep /^z/, keys %g;
my $max = substr $z[-1], 1;
for my $z (@z[ 0 .. $#z - 1]) {
    $err{$z} |= 1 if ! exists $g{$z}{XOR};
    $err{$z} |= 2 if $r{$z};
    my $id = substr $z, 1;
    if ($g{$z}{XOR}) {
        my @args = keys %{ $g{$z}{XOR} };

        if ('00' ne $id) {
            if(grep /^[xy]/, @args) {
                $err{$z} |= 4;
            } elsif ('01' ne $id) {
                my @xor = grep exists $g{$_}{XOR}, @args;
                my @or  = grep exists $g{$_}{OR},  @args;
                $err{$z} |=  8 if 1 != @or;
                $err{$z} |= 16 if 1 != @xor;
                for my $arg (@args) {
                    if (my @xy = sort keys %{ $g{$arg}{XOR} // {} }) {
                        $err{$arg} |= 32
                            if "@xy" ne "x$id y$id";
                    }
                }
            }
        }
    }
}
for my $n (grep /^[^xyz]/, keys %g) {
    if ($g{$n}{AND}) {
        $err{$n} |= 64 if ! exists $r{$n}{OR} || 1 < keys %{ $r{$n} };

    } elsif ($g{$n}{OR} || $g{$n}{XOR}) {
        $err{$n} |= 128 if ! exists $r{$n}{AND}
                        || ! exists $r{$n}{XOR}
                        || exists $r{$n}{OR};
        if ($g{$n}{XOR}) {
            $err{$n} |= 256 if grep /^[^z]/, keys %{ $r{$n}{XOR} };
        }
    }
}
for my $x (grep /^x/, keys %g) {
    my $id = substr $x, 1;
    my @xxor      =     keys %{ $r{$x}{XOR} };
    my @xand      =     keys %{ $r{$x}{AND} };
    my @xxorxor   = map keys %{ $r{$_}{XOR} }, @xxor;
    my @xxorand   = map keys %{ $r{$_}{AND} }, @xxor;
    my @xxorandor = map keys %{ $r{$_}{OR} }, @xxorand;
    my @xandor    = map keys %{ $r{$_}{OR} }, @xand;
    my @xandorxor = map keys %{ $r{$_}{XOR} }, @xandor;

    $err{$x} |=  512 if @xxorxor != 1 || $xxorxor[0] ne "z$id";
    $err{$x} |= 1024 if 1 != @xxorandor
                     || 1 != @xandor
                     || $xxorandor[0] ne $xandor[0];
    $err{$x} |= 2048 if $id != $max - 1
                     && (@xandorxor != 1
                         || $xandorxor[0] ne 'z' . sprintf '%02d', $id + 1);

    my $y = "y$id";
    my @yxor    =     keys %{ $r{$y}{XOR} };
    my @yxorxor = map keys %{ $r{$_}{XOR} }, @yxor;
    $err{$y} |= 512 if @yxorxor != 1 || $yxorxor[0] ne "z$id";
}

# GRAPHVIZ

my %SHORT = (AND => '&', OR => '|', XOR => '^');

say 'strict digraph { rankdir = LR';

for my $r (sort keys %g) {
    my $op = (keys %{ $g{$r} })[0];
    next unless $op;
    my ($arg1, $arg2) = keys %{ $g{$r}{$op} };
    say qq{${r}O [label="$SHORT{$op}", shape=box, color=grey]};
    for my $n ($arg1, $arg2, $r) {
        my $c = $COLOR{ substr $n, 0, 1 } // 'black';
        my $e = $err{$n}
                  ? qq{,style=filled,fillcolor=red,label="$n\\n$err{$n}"}
                  : "";
        warn $e if $e;
        say qq{$n\ [color=$c $e]} if $c || $e;
    }
    say "${r}O -> ${r}";
    say "$arg1 -> ${r}O";
    say "$arg2 -> ${r}O";
}
say '}';
