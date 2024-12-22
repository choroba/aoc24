#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };
use experimental qw( signatures );

use ARGV::OrDATA;

{   package Secret;
    sub new($c, $v) {
        my $self = bless {value => $v}, $c;
        $self->{price} = $v % 10;
        return $self
    }

    sub mix($self, $n) { $self->{value} = $self->{value} ^ $n }

    sub prune($self) { $self->{value} = $self->{value} % 16777216 }

    sub Next($self) {
        $self->mix(64 * $self->{value});
        $self->prune;

        $self->mix(int($self->{value} / 32));
        $self->prune;

        $self->mix($self->{value} * 2048);
        $self->prune;

        $self->{old_price} = $self->{price};
        $self->{price} = $self->{value} % 10;
        push @{ $self->{history} }, $self->{price} - $self->{old_price}
            if defined $self->{old_price};
        shift @{ $self->{history} } if @{ $self->{history} } > 4;
    }
}

sub test {
    my @values = qw( -3 6 -1 -1 0 2 -2 0 -2 );
    my $s = 'Secret'->new(123);
    for (1 .. 9) {
        $s->Next;
        my $exp = shift @values;
        die "T1: $s->{value} $s->{history}[-1] != $exp"
            unless $s->{history}[-1] == $exp;
    }

    $s = 'Secret'->new(123);
    while (1) {
        $s->Next;
        last if $s->{price} == 6 && @{ $s->{history} } > 2;
    }
    "@{ $s->{history} }" eq '-1 -1 0 2' or die "T2: @{ $s->{history} }";

    say 'Ok';
}

test();

my $sum = 0;
my %seen;
my @max = (0);
while (my $line = <>) {
    chomp $line;
    my $s = 'Secret'->new($line);
    for (1 .. 2000) {
        $s->Next;
        my $h = "@{ $s->{history} }";
        unless (exists $seen{$h}{$.}) {
            undef $seen{$h}{$.};
            $seen{$h}{SUM} += $s->{price};
            if ($seen{$h}{SUM} > $max[0]) {
                @max = ($seen{$h}{SUM}, $h);
            }
        }
    }
}

say $max[0];

__DATA__
1
2
3
2024
