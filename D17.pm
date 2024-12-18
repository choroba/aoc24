package Computer;
use Moo;
use experimental qw( signatures );

use Sub::Util qw{ subname };
use namespace::clean;

has [qw[ A B C ]] => (is => 'rw');
has 'IP'          => (is => 'rwp', default => 0);
has program       => (is => 'ro');
has output        => (is => 'ro', default => sub {[]});
has halted        => (is => 'rwp', default => 0);

my %INSTRUCTION = (
    0 => \&adv,
    1 => \&bxl,
    2 => \&bst,
    3 => \&jnz,
    4 => \&bxc,
    5 => \&out,
    6 => \&bdv,
    7 => \&cdv
);

sub combo($self, $operand) {
    return $operand if 0 <= $operand && $operand <= 3;
    return $self->A if 4 == $operand;
    return $self->B if 5 == $operand;
    return $self->C if 6 == $operand;
    die 'Invalid combo operand 7';
}

sub adv($self, $operand) {
    $self->A(int($self->A / 2 ** $self->combo($operand)));
    return
}

sub bxl($self, $operand) {
    $self->B($self->B ^ $operand);
    return
}

sub bst($self, $operand) {
    $self->B($self->combo($operand) % 8);
    return
}

sub jnz($self, $operand) {
    return if $self->A == 0;
    return $operand
}

sub bxc($self, $) {
    $self->B($self->B ^ $self->C);
    return
}

sub out($self, $operand) {
    push @{ $self->output }, $self->combo($operand) % 8;
    return
}

sub bdv($self, $operand) {
    $self->B(int($self->A / 2 ** $self->combo($operand)));
    return
}

sub cdv($self, $operand) {
    $self->C(int($self->A / 2 ** $self->combo($operand)));
    return
}

sub step($self, $verbose = 0) {
    my $instruction = $self->program->[ $self->IP ];
    my $operand = $self->program->[ 1 + $self->IP ];
    my $sub = $INSTRUCTION{$instruction};
    if ($verbose) {
        my $name = subname($sub) =~ s/.*:://r;
        print $self->IP, "\t", $name;
        print " ", $self->show_operand($instruction, $operand);
        print "\t", '[', join( ', ', map $self->$_, qw( A B C )), ']';
        print ' "', join(',', @{ $self->output }), '"';
        print "\n";
    }

    die "No implementation of $instruction." unless defined $sub;
    my $jumped = $self->$sub($operand);
    $jumped //= 2 + $self->IP;
    $self->_set_halted(1) if $jumped > $#{ $self->program };
    $self->_set_IP($jumped);
}

sub show_operand($self, $instruction, $operand) {
    return if 4 == $instruction;
    return $operand if $instruction =~ /^[13]$/
                    || 0 <= $operand && $operand <= 3;
    return 'A' if 4 == $operand;
    return 'B' if 5 == $operand;
    return 'C' if 6 == $operand;
    return 'Invalid combo operand 7'
}

sub listing($self) {
    my $i = 0;
    my $p = $self->program;
    while ($i < $#$p) {
        my $name = subname($INSTRUCTION{ $p->[$i] }) =~ s/.*:://r;
        print $i, "\t", $name;
        print " ", $p->[ $i + 1 ];
        print "\n";
        $i += 2;
    }
}

__PACKAGE__
