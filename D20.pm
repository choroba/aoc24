package D20;

use warnings;
use strict;
use experimental qw( signatures );
use feature qw{ say };

use Exporter qw{ import };
our @EXPORT_OK = qw{ solve };

use List::Util qw{ sum0 };

sub solve($CHEAT_SIZE, $THRESHOLD) {
    my @DIRS = ([0, 1], [0, -1], [1, 0], [-1, 0]);
    my @CHEATS;
    for my $y (-$CHEAT_SIZE .. $CHEAT_SIZE) {
        for my $x (-$CHEAT_SIZE .. $CHEAT_SIZE) {
            push @CHEATS, [$y, $x] if ($y != 0  || $x != 0)
                                   && abs($y) + abs($x) <= $CHEAT_SIZE;
        }
    }

    my ($sx, $sy, $ex, $ey);
    my @grid;
    while (<>) {
        chomp;
        push @grid, [split //];
        ($sx, $sy) = map $_ - 1, pos, $. if /S/g;
        ($ex, $ey) = map $_ - 1, pos, $. if /E/g;
    }

    my %agenda = (pack('CC', $sx, $sy) => undef);

    my @distance;
    $distance[$sy][$sx] = 0;

    while (keys %agenda) {
        my %next;
        for my $xy (keys %agenda) {
            my ($x, $y) = unpack 'CC', $xy;
            for my $dir (@DIRS) {
                my $nx = $x + $dir->[0];
                my $ny = $y + $dir->[1];
                if ('#' ne $grid[$ny][$nx]
                    && ! defined $distance[$ny][$nx]) {
                    undef $next{ pack 'CC', $nx, $ny };
                    $distance[$ny][$nx] = $distance[$y][$x] + 1;
                }
            }
        }
        %agenda = %next;
    }

    my %cheats;
    for my $y (1 .. $#grid - 1) {
        for my $x (1 .. $#{ $grid[0] } - 1) {
            next if '#' eq $grid[$y][$x];

            for my $c (@CHEATS) {
                my $cx = $x + $c->[0];
                my $cy = $y + $c->[1];

                next if $cy < 0 || $cy > $#grid;
                next if $cx < 0 || $cx > $#{ $grid[0] };
                next unless defined $distance[$cy][$cx];

                my $d = abs($c->[0]) + abs($c->[1]);
                next if $distance[$y][$x] + $d >= $distance[$cy][$cx];

                ++$cheats{ $distance[$cy][$cx] - $distance[$y][$x] - $d };
            }
        }
    }

    say "$cheats{$_} $_" for sort { $a <=> $b }
                             grep $_ >= $THRESHOLD,
                             keys %cheats;
    return sum0(@cheats{ grep $_ >= $THRESHOLD, keys %cheats })
}

__PACKAGE__
