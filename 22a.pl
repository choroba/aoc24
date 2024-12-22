#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

{   package Secret;
    sub new($c, $v) { bless {value => $v}, $c }

    sub mix($self, $n) { $self->{value} = $self->{value} ^ $n }

    sub prune($self) { $self->{value} = $self->{value} % 16777216 }

    sub Next($self) {
        $self->mix(64 * $self->{value});
        $self->prune;

        $self->mix(int($self->{value} / 32));
        $self->prune;

        $self->mix($self->{value} * 2048);
        $self->prune;
    }
}

sub test {
    my $s = 'Secret'->new(42);
    $s->mix(15);
    die $s->{value} unless $s->{value} == 37;

    $s->{value} = 100000000;
    $s->prune;
    die $s->{value} unless $s->{value} == 16113920;

    $s->{value} = 123;
    my @values = qw(15887950 16495136 527345 704524 1553684 12683156 11100544
                    12249484 7753432 5908254 );
    while (@values) {
        $s->Next;
        die $s->{value} unless $s->{value} == shift @values;
    }
    say 'Ok';
}

test();

my $sum = 0;
while (my $line = <>) {
    chomp $line;
    my $s = 'Secret'->new($line);
    $s->Next for 1 .. 2000;
    $sum += $s->{value};
}
say $sum;

__DATA__
1
10
100
2024
