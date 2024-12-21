#!/usr/bin/perl
use warnings;
use strict;
use experimental qw( signatures );
use feature qw{ say };

use ARGV::OrDATA;
use List::Util qw{ min };
use Memoize;

my $MAX_DEPTH = 25;

my %DIRS = ('<' => [-1, 0], '>' => [1, 0],
            '^' => [0, -1], 'v' => [0, 1]);

my @KEYPADS = ({keys => [[ 7, 8, 9],
                         [ 4, 5, 6],
                         [ 1, 2, 3],
                         [-1, 0, 'A']]},

               {keys => [[-1,  '^', 'A'],
                         ['<', 'v', '>']]});

for my $keypad (@KEYPADS) {
    my $keys = $keypad->{keys};
    my %coord;
    for my $y (0 .. $#$keys) {
        for my $x (0 .. $#{ $keys->[0] }) {
            $keypad->{coord}{ $keys->[$y][$x] } = [$x, $y];
        }
    }
    for my $from (keys %{ $keypad->{coord} }) {
        next if '-1' eq $from;

        $keypad->{path}{$from}{$from} = {"" => undef};

        my %agenda = ("" => $keypad->{coord}{$from});
        while (keys %agenda) {
            my %next;
            for my $path (keys %agenda) {
                my ($x, $y) = @{ $agenda{$path} };
                for my $key (keys %DIRS) {
                    my $newpath = $path . $key;

                    # No zigzag, it's expensive.
                    next if $newpath =~ / ([<>]) [v^]+ \1
                                        | ([v^]) [<>]+ \2 /x;

                    my $nx = $x;
                    my $ny = $y;
                    if ('A' ne $key) {
                        $nx += $DIRS{$key}[0];
                        $ny += $DIRS{$key}[1];
                    }
                    next if $ny < 0 || $nx < 0
                         || $ny > $#{ $keypad->{keys} }
                         || $nx > $#{ $keypad->{keys}[0] }
                         || '-1' eq $keypad->{keys}[$ny][$nx];

                    my $to = $keypad->{keys}[$ny][$nx];

                    if (exists $keypad->{path}{$from}{$to}) {
                        my $old = (keys %{ $keypad->{path}{$from}{$to} })[0];
                        $keypad->{path}{$from}{$to} = {}
                            if length $newpath < length $old;
                        undef $keypad->{path}{$from}{$to}{$newpath}
                            if length $newpath <= length $old;
                    } else {
                        undef $keypad->{path}{$from}{$to}{$newpath}
                    }
                    $next{$newpath} = [$nx, $ny]
                        if exists $keypad->{path}{$from}{$to}{$newpath};
                }
            }
            %agenda = %next;
        }
    }
}

memoize('solve');
sub solve($segment, $depth, $=) {
    my $keypad_index = $depth == $MAX_DEPTH ? 0 : 1;
    my $keypad = $KEYPADS[$keypad_index];

    my $__prefix = '    ' x ($MAX_DEPTH - $depth);

    return type($segment, $keypad_index, $__prefix) if 0 == $depth;

    my $sum = 0;
    for my $pos (1 .. length $segment) {
        my $from = substr "A$segment", $pos - 1, 1;
        my $to   = substr $segment, $pos - 1, 1;
        $sum += min(map solve($_ . 'A', $depth - 1),
                    keys %{ $keypad->{path}{$from}{$to} });
    }
    return $sum
}

sub type($segment, $keypad_index, $__prefix) {
    my $keypad = $KEYPADS[$keypad_index];
    my $length = 0;
    for my $pos (1 .. length $segment) {
        my $from = substr "A$segment", $pos - 1, 1;
        my $to   = substr $segment, $pos - 1, 1;
        $length += min(map length, keys %{ $keypad->{path}{$from}{$to} })
                   + 1;  # This is the final "A" to confirm the path.
    }
    return $length
}

my $complexity = 0;
while (my $code = <>) {
    chomp $code;
    my $num = $code =~ s/\D//gr;
    my $s = solve($code, $MAX_DEPTH);
    my $length = $s;

    say "$length * $num";
    $complexity += $length * $num;
}

say $complexity;

__DATA__
029A
980A
179A
456A
379A
