package MaxMind::DB::Reader::XS;
$MaxMind::DB::Reader::XS::VERSION = '1.000000';
use strict;
use warnings;
use namespace::autoclean;

use 5.010000;

use Math::Int128 qw( uint128 );
use MaxMind::DB::Metadata;
use MaxMind::DB::Reader 1.000000;
use MaxMind::DB::Types qw( Int );

use Moo;

with 'MaxMind::DB::Reader::Role::Reader',
    'MaxMind::DB::Reader::Role::HasMetadata';

use XSLoader;

XSLoader::load(
    __PACKAGE__,
    exists $MaxMind::DB::Reader::XS::{VERSION}
        && ${ $MaxMind::DB::Reader::XS::{VERSION} }
    ? ${ $MaxMind::DB::Reader::XS::{VERSION} }
    : '42'
);

has _mmdb => (
    is        => 'ro',
    init_arg  => undef,
    lazy      => 1,
    builder   => '_build_mmdb',
    predicate => '_has_mmdb',
);

# XXX - making this private & hard coding this is obviously wrong - eventually
# we need to expose the flag constants in Perl
has _flags => (
    is       => 'ro',
    isa      => Int,
    init_arg => undef,
    default  => 0,
);

sub BUILD { $_[0]->_mmdb }

sub _data_for_address {
    my $self = shift;

    return $self->__data_for_address( $self->_mmdb(), @_ );
}

sub _read_node {
    my $self = shift;

    return $self->__read_node( $self->_mmdb(), @_ );
}

sub _get_entry_data {
    my $self = shift;

    return $self->__get_entry_data( $self->_mmdb(), @_ );
}

sub _build_mmdb {
    my $self = shift;

    return $self->_open_mmdb( $self->file(), $self->_flags() );
}

sub _build_metadata {
    my $self = shift;

    my $raw = $self->_raw_metadata( $self->_mmdb() );

    return MaxMind::DB::Metadata->new($raw);
}

sub DEMOLISH {
    my $self = shift;

    $self->_close_mmdb( $self->_mmdb() )
        if $self->_has_mmdb();

    return;
}

sub _decode_bigint {
    my $buffer = shift;

    my $int = uint128(0);

    my @unpacked = unpack( 'NNNN', _zero_pad_left( $buffer, 16 ) );
    for my $piece (@unpacked) {
        $int = ( $int << 32 ) | $piece;
    }

    return $int;
}

# Copied from MaxMind::DB::Reader::Decoder
sub _zero_pad_left {
    my $content        = shift;
    my $desired_length = shift;

    return ( "\x00" x ( $desired_length - length($content) ) ) . $content;
}

__PACKAGE__->meta()->make_immutable();

1;

# ABSTRACT: Fast XS implementation of MaxMind DB reader

__END__

=pod

=encoding UTF-8

=head1 NAME

MaxMind::DB::Reader::XS - Fast XS implementation of MaxMind DB reader

=head1 VERSION

version 1.000000

=head1 SYNOPSIS

    my $reader = MaxMind::DB::Reader->new( file => 'path/to/database.mmdb' );

    my $record = $reader->record_for_address('1.2.3.4');

=head1 DESCRIPTION

Simply installing this module causes L<MaxMind::DB::Reader> to use the XS
implementation, which is much faster than the Perl implementation.

The XS implementation links against the
L<libmaxminddb|http://maxmind.github.io/libmaxminddb/> library.

See L<MaxMind::DB::Reader> for API details.

=head1 VERSIONING POLICY

This module uses semantic versioning as described by
L<http://semver.org/>. Version numbers can be read as X.YYYZZZ, where X is the
major number, YYY is the minor number, and ZZZ is the patch number.

=head1 SUPPORT

Please report all issues with this code using the GitHub issue tracker at
L<https://github.com/maxmind/MaxMind-DB-Reader-XS/issues>.

=head1 AUTHORS

=over 4

=item *

Boris Zentner <bzentner@maxmind.com>

=item *

Dave Rolsky <drolsky@maxmind.com>

=item *

Ran Eilam <reilam@maxmind.com>

=back

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by MaxMind, Inc..

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
