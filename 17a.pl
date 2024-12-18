#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

use FindBin;
use lib $FindBin::Bin;
use D17;

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

my $computer = 'Computer'->new(program => \@program, %register);
$computer->step until $computer->halted;

say join ',', @{ $computer->output };

__DATA__
Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0
