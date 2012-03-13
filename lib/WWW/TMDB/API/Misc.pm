package WWW::TMDB::API::Misc;

use strict;
use warnings;
our $VERSION = '0.02';

sub genres {
    my $self = shift;
    my (%params) = @_;
    $self->{api}->send_api('Genres.getList');
}

1;

