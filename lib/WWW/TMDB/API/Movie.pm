package WWW::TMDB::API::Movie;

use strict;
use warnings;
our $VERSION = '0.02';

sub browse {
    my $self = shift;
    my (%params) = @_;

    $self->{api}->send_api(
        'Movie.browse',
        {   order_by        => 1,    #rating, release, title
            order           => 1,    #asc, desc
            per_page        => 0,
            page            => 0,
            query           => 0,
            min_votes       => 0,
            rating_min      => 0,
            rating_max      => 0,
            genres          => 0,
            genres_selector => 0,
            release_min     => 0,
            year            => 0,
            certifications  => 0,
            companies       => 0,
            countries       => 0
        },
        \%params
    );
}

sub images {
    my $self = shift;
    my (%params) = @_;
    $self->{api}->send_api( 'Movie.getImages', { 'ID' => 1 }, \%params );
}

sub info {
    my $self = shift;
    my (%params) = @_;
    $self->{api}->send_api( 'Movie.getInfo', { 'ID' => 1 }, \%params );
}

sub latest {
    my $self = shift;
    $self->{api}->send_api('Movie.getLatest');
}

sub translations {
    my $self = shift;
    my (%params) = @_;
    $self->{api}
        ->send_api( 'Movie.getTranslations', { 'ID' => 1 }, \%params );
}

sub version {
    my $self = shift;
    my (%params) = @_;
    $self->{api}->send_api( 'Movie.getVersion', { 'ID' => 1 }, \%params );
}

sub imdb_lookup {
    my $self = shift;
    my (%params) = @_;
    $self->{api}
        ->send_api( 'Movie.imdbLookup', { 'IMDB ID' => 1 }, \%params );
}

sub search {
    my $self = shift;
    my (%params) = @_;
    $self->{api}->send_api( 'Movie.search', { 'Title' => 1 }, \%params );
}

1;

