package WWW::TMDB::API::Person;

use strict;
use warnings;
our $VERSION = '0.01';

sub info {
    my $self = shift;
    my (%params) = @_;
    $self->api->send_api( 'Person.getInfo', { ID => 1 }, \%params );
}

sub version {
    my $self = shift;
    my (%params) = @_;
    $self->api->send_api( 'Person.getVersion', { ID => 1 }, \%params );
}

sub search {
    my $self = shift;
    my (%params) = @_;
    $self->api->send_api( 'Person.search', { Name => 1 }, \%params );
}

sub latest {
    my $self = shift;
    my (%params) = @_;
    $self->api->send_api('Person.getLatest');
}

1;

