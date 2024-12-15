#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;
use Memoize qw{ memoize flush_cache };

my $DEBUG;
BEGIN {
    $DEBUG = 0;
}
use if $DEBUG, 'Data::Dumper';

*debug = $DEBUG ? sub ($prefix, @arr) {
    warn $prefix, map ref ? Dumper $_ : $_, @arr if $DEBUG;
} : sub {};

my %DIR = ( '^' => [0, -1],
            '>' => [1, 0],
            'v' => [0, 1],
            '<' => [-1, 0]);

my %UPDATE = do { no warnings 'qw'; qw( # ## O [] . .. @ @. ) };

my @grid;
my @moves;
my ($x, $y);
my $mode = 0;
while (<>) {
    chomp;
    $mode = 1, next if "" eq $_;

    if (0 == $mode) {
        s/(.)/$UPDATE{$1}/g;
        push @grid, [split //];
        if (/@/g) {
            $y = ($. - 1);
            $x = pos($_) - 1;
        }
    } else {
        push @moves, split //;
    }
}
$grid[$y][$x] = '.';

sub move($xr, $yr, $nx, $ny, $) {
    $$xr = $nx;
    $$yr = $ny;
}

sub Push($xr, $yr, $nx, $ny, $dir) {
    my $p = pushable($nx, $ny, $dir);
    debug("", p => $p);

    my @boxes = map [split], keys %$p;
    return unless @boxes;

    debug("", boxes => \@boxes);

    my @changes;
    for my $box (@boxes) {
        my ($bx, $by) = @$box;
        --$bx if ']' eq $grid[$by][$bx];
        push @changes, [$bx, $by, '.'], [1 + $bx, $by, '.'];
    }

    for my $box (@boxes) {
        my ($bx, $by) = @$box;
        --$bx if ']' eq $grid[$by][$bx];
        $bx += $dir->[0];
        $by += $dir->[1];
        push @changes, [$bx, $by, '['], [1 + $bx, $by, ']'];
    }

    for my $change (@changes) {
        my ($x, $y, $char) = @$change;
        $grid[$y][$x] = $char;
    }

    $$xr = $nx;
    $$yr = $ny;
}

my %pushable_cache;
sub pushable($x, $y, $dir, $depth = 0) {
    my $cache_key = "$_[0] $_[1] @{ $_[2] }";
    return $pushable_cache{$cache_key}
        if exists $pushable_cache{$cache_key};

    my $prefix = '  ' x $depth;
    my $nx = $x + 2 * $dir->[0];
    my $ny = $y + $dir->[1];
    debug($prefix, "able? $x $y => $nx $ny");
    return $pushable_cache{$cache_key} = {}
        if '#' eq $grid[$ny][$nx];

    debug($prefix, "A");

    if ($dir->[0]) {
        debug($prefix, "B");
        return $pushable_cache{$cache_key}
            = {"$x $y" => undef}
            if '.' eq $grid[$ny][$nx];
        debug($prefix, "C");
        my $p = pushable($nx, $ny, $dir, $depth + 1);
        return $pushable_cache{$cache_key}
            = keys %$p ? {"$x $y" => undef, %$p } : {}

    } else {
        my $ox = $x + (('[' eq $grid[$y][$x]) ? 1 : -1);
        debug($prefix, "D $x/$ox $y");

        return $pushable_cache{$cache_key} = {}
            if '#' eq $grid[$ny][$ox];

        # vert is one of "[", "]", "."
        ($x, $ox) = ($ox, $x) if $ox < $x;
        debug($prefix, "E $x/$ox $ny");
        my $vert0 = $grid[$ny][$x];
        my $vert1 = $grid[$ny][$ox];
        return $pushable_cache{$cache_key}
            = {"$x $y" => undef}
            if '.' eq $vert0 && '.' eq $vert1;

        my $p1 = '.' ne $vert0 ? pushable($x,  $ny, $dir, $depth + 1)
                               : {"$x $y" => undef};
        my $p2 = '.' ne $vert1 ? pushable($ox, $ny, $dir, $depth + 1)
                               : {"$x $y" => undef};
        debug($prefix, 'p1 ', map("[$_]", keys %$p1),
            "\n${prefix}p2 ", map("[$_]", keys %$p2));

        return $pushable_cache{$cache_key} = {}
            unless keys %$p1 && keys %$p2;

        return $pushable_cache{$cache_key}
            = {"$x $y" => undef, %$p1, %$p2}
    }
}

if ($DEBUG) {
    $grid[$y][$x] = '@';
    print ' ';
    print 0..9 for 0 .. @grid / 10;
    say "";
    my $i = 0;
    say +($i = ($i + 1) % 10), @$_ for @grid;
    say "";
}

$grid[$y][$x] = '.';


my %DISPATCH = (
    '#' => undef,
    '[' => \&Push,
    ']' => \&Push,
    '.' => \&move
);

my $step = 0;
for my $move (@moves) {
    my $dir = $DIR{$move};
    my $nx = $x + $dir->[0];
    my $ny = $y + $dir->[1];
    my $what = $grid[$ny][$nx];

    %pushable_cache = ();
    $DISPATCH{$what}->(\$x, \$y, $nx, $ny, $dir) if defined $DISPATCH{$what};

    if ($DEBUG) {
        say $move, ' ', $step++, '/', scalar @moves;
        $grid[$y][$x] = $move;
        print ' ';
        print 0..9 for 1 .. @{ $grid[0] } / 10;
        say "";
        my $i = -1;
        say +($i = ($i + 1) % 10), @$_ for @grid;
        say "";
        use Time::HiRes qw{ usleep };
        usleep((($DISPATCH{$what} // 0) == \&Push) * 250_000 + 100_000)
            if $step > 0;
    }

    $grid[$y][$x] = '.';
}

my $gps = 0;
for my $y (0 .. $#grid) {
    for my $x (0 .. $#{ $grid[0] }) {
        $gps += 100 * $y + $x if '[' eq $grid[$y][$x];
    }
}

say $gps;

__DATA__
########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

<^^>>>vv<v>>v<<
