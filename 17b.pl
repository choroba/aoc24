#!/usr/bin/perl
use warnings;
use strict;
use experimental qw( signatures );
use feature qw{ say };

use ARGV::OrDATA;
use List::Util qw{ min };

use FindBin;
use lib $FindBin::Bin;
use D17;

sub np_oct($oct) {
    no warnings 'portable';
    oct "0$oct"
}

my %register;
my @program;
while (<>) {
    chomp;
    if (/Register (.): (\d+)/) {
        $register{$1} = $2;
    } elsif (/Program: ([\d,]+)/) {
        @program = split /,/, $1;
    } elsif ($_ ne "") {
        die "Invalid input; $_.\n";
    }
}

my $p = reverse join "", @program;
my @inputs = (0 .. 7);
my %quines;
while (@inputs) {
    my @next;
    for my $input (@inputs) {
        $register{A} = np_oct($input);
        my $computer = 'Computer'->new(program => \@program, %register);
        until ($computer->halted) {
            $computer->step(0);
        }
        my $o = reverse join "", @{ $computer->output };
        undef $quines{$input} if $o eq $p;
        push @next, map "$input$_", 0 .. 7
            if 0 == index $p, $o;
    }
    @next = map { my $in = $_; map "$in$_", 0 .. 7 } @inputs
        if ! keys %quines && ! @next;
    @inputs = @next;
}

say np_oct(min(keys %quines));

__DATA__
Register A: 2024
Register B: 0
Register C: 0

Program: 0,3,5,4,3,0
