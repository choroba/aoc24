#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

{   package MyQueue;
    use List::Util qw{ min };

    sub new($class) { bless {prios => {}, queue => {}}, $class }

    sub insert($self, $payload, $priority) {
        if (exists $self->{prios}{$payload}) {
            my $old_priority = $self->{prios}{$payload};
            return if $old_priority < $priority;

            @{ $self->{queue}{$old_priority} }
                = grep $_ ne $payload,
                  @{ $self->{queue}{$old_priority} };
        }
        $self->{prios}{$payload} = $priority;
        $self->{min_key} = $priority
            if ! exists $self->{min_key} || $priority < $self->{min_key};
        push @{ $self->{queue}{$priority} }, $payload;
    }

    sub pull($self) {
        my $payload  = shift @{ $self->{queue}{ $self->{min_key} } };
        my $priority = delete $self->{prios}{$payload};

        if (! @{ $self->{queue}{$priority} }) {
            delete $self->{queue}{$priority};
            if (my @prios = keys %{ $self->{queue} }) {
                $self->{min_key} = min(@prios);
            } else {
                delete $self->{min_key};
            }
        }
        return $payload, $priority
    }
}

my @DIRS = ([1, 0], [0, 1], [-1, 0], [0, -1]); # East first.
my $ROTATION_PRICE = 1000;
my $MOVEMENT_PRICE = 1;

my ($sx, $sy);
my @grid;
while (<>) {
    chomp;
    push @grid, [split //];
    ($sx, $sy) = (pos($_) - 1, $. - 1) if /S/g;
}

my $agenda = 'MyQueue'->new;
$agenda->insert(pack('CCC', $sx, $sy), 0);
my %best_for_tile;
my $winning_score = 'Inf';
while (1) {
    my ($xyd, $score) = $agenda->pull;

    last if $score > $winning_score;

    next if exists $best_for_tile{$xyd} && $best_for_tile{$xyd} < $score;

    $best_for_tile{$xyd} = $score;
    my ($x, $y, $dir) = unpack 'CCC', $xyd;
    $winning_score = $score, last
        if 'E' eq $grid[$y][$x];

    my $nx = $x + $DIRS[$dir][0];
    my $ny = $y + $DIRS[$dir][1];
    $agenda->insert(pack('CCC', $nx, $ny, $dir), $score + $MOVEMENT_PRICE)
        unless '#' eq $grid[$y][$x];

    for my $newdir (map $_ % @DIRS, $dir + 1, $dir - 1) {
        $agenda->insert(pack('CCC', $x, $y, $newdir), $score + $ROTATION_PRICE);
    }
}

my %visited;
my @paths = ([pack 'NCCC', 0, $sx, $sy, 0]);
while (@paths) {
    my @next;
    for my $path (@paths) {
        my ($score, $x, $y, $dir) = unpack 'NCCC', $path->[-1];

        my $xyd = pack 'CCC', $x, $y, $dir;
        next if ! exists $best_for_tile{$xyd} || $best_for_tile{$xyd} < $score;

        if ('E' eq $grid[$y][$x] && $score == $winning_score) {
            @visited{ map join(' ', unpack 'x[N]CC', $_), @$path } = ();
        }

        for my $ndir (map +(($dir + $_) % @DIRS), -1, 1) {
            push @next, [@$path,
                         pack 'NCCC', $score + $ROTATION_PRICE, $x, $y, $ndir];
        }
        my $nx = $x + $DIRS[$dir][0];
        my $ny = $y + $DIRS[$dir][1];
        push @next, [@$path,
                     pack 'NCCC', $score + $MOVEMENT_PRICE, $nx, $ny, $dir]
            if '#' ne $grid[$ny][$nx];
    }
    @paths = @next;
}

say scalar keys %visited;

__DATA__
###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############
