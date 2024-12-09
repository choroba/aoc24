#!/usr/bin/perl
use warnings;
use strict;
use feature qw{ say };

use ARGV::OrDATA;

chomp( my $disk_map = <> );

my $id = 1;
my $disk;
while ($disk_map =~ /(.)(.)/g) {
    my $file_length  = $1;
    my $space_length = $2;
    $disk .= pack('U', $id) x $file_length;
    $disk .= "\0" x $space_length;
    ++$id;
}
$disk .= pack('U', $id) x $1 if 1 == length($disk_map) % 2
                             && $disk_map =~ /(.)$/;
while ($id >= 0) {
    my $chr = pack 'U', $id;
    $disk =~ /(\Q$chr\E+)/;
    my $file = $1;
    my $length = length $file;
    $disk =~ s/(.*)\Q$chr\E{$length}/"$1" . ("\x00" x $length)/se
        if $disk =~ s/\x00{$length}/$file/;
    --$id;
}

my $checksum = 0;
my $pos = 0;
while ($disk =~ /(.)/gs) {
    my $id = unpack('U', $1) - 1;
    $checksum += $pos * $id if $id >= 0;
    ++$pos;
}

say $checksum;

__DATA__
2333133121414131402
12345
