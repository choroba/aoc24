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
                  @{ $self->{queue}{$old_priority} }; # SLOW
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
                $self->{min_key} = min(@prios); # TODO
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

my ($x, $y);
my @grid;
while (<>) {
    chomp;
    push @grid, [split //];
    ($x, $y) = (pos($_) - 1, $. - 1) if /S/g;
}

my $agenda = 'MyQueue'->new;
$agenda->insert("$x $y 0", 0);
my %best;
while (1) {
    my ($xyd, $score) = $agenda->pull;
    my ($x, $y, $dir) = split / /, $xyd;

    next if exists $best{$xyd} && $best{$xyd} < $score;

    $best{$xyd} = $score;

    say($score), last if 'E' eq $grid[$y][$x];

    my $nx = $x + $DIRS[$dir][0];
    my $ny = $y + $DIRS[$dir][1];
    $agenda->insert("$nx $ny $dir", $score + $MOVEMENT_PRICE)
        unless '#' eq $grid[$y][$x];

    for my $newdir (map $_ % @DIRS, $dir + 1, $dir - 1) {
        $agenda->insert("$x $y $newdir", $score + $ROTATION_PRICE);
    }
}

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
