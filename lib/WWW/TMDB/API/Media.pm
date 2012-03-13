package WWW::TMDB::API::Media;

use strict;
use warnings;
our $VERSION = '0.03';

sub info {
    my $self = shift;
    my (%params) = @_;
    $self->{api}->send_api( 'Media.getInfo', { 'ID' => 1 }, \%params );
}

1;

