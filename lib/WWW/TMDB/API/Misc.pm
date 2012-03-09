package WWW::TMDB::API::Misc;

use strict;
use warnings;
our $VERSION = '0.01';

sub genres {
    my $self = shift;
    my (%params) = @_;
    $self->{api}->send_api('Genres.getList');
}

1;

