package WWW::TMDB::API;

use 5.006;
use strict;
use warnings;
use Carp;

our $VERSION = '0.01';
use utf8;
use LWP::UserAgent;
use JSON;
use URI;

our @namespaces = qw( Person Movie Media Misc);
for (@namespaces) {
    my $package = __PACKAGE__ . "::$_";
    my $name    = "\L$_";
    eval qq(
    use $package;
    sub $name {
      my \$self = shift;
      if ( \$self->{'_$name'} ) {
        return \$self->{'_$name'};
      }else{
        \$self->{'_$name'} = $package->new( api => \$self );
      }
    };

    package $package;
    sub api {
      return shift->{api};
    };

    sub new {
      my ( \$class, \%params ) = \@_;
      my \$self = bless \\\%params, \$class;
      \$self->{api} = \$params{api};
      return \$self;
    };

    1;
  );
  croak "Cannot create namespace $name: $@\n" if $@;
}

sub send_api {
    my ( $self, $command, $params_spec, $params ) = @_;

    $self->check_parameters( $params_spec, $params );
    my $url = $self->url( $command, $params );
    my $json_response = $self->{ua}->get($url);
    
    if ( $json_response->is_success ) {
        return decode_json $json_response->content();
    }
    else {
        croak sprintf( "%s returned by %s", $json_response->status_line, $url );
    }
}

# Checks items that will be sent to the API($input)
# $params - an array that identifies valid parameters 
#     example :
#     {'ID' => 1 }, 1- field is required, 0- field is optional
sub check_parameters {
    my $self = shift;
    my ( $params, $input ) = @_;

    foreach my $k ( keys(%$params) ) {
        croak "Required parameter $k missing."
            if ( $params->{$k} == 1 and !defined $input->{$k} );
    }
    foreach my $k ( keys(%$input) ) {
        croak "Unknown parameter - $k." if ( !defined $params->{$k} );
    }
}

sub url {
    my $self = shift;
    my ( $command, $params ) = @_;
    my $url = new URI( $self->{url} );
    if ( keys(%$params) == 1 ) {
        my ( $key, $value ) = each(%$params);
        $url->path_segments( $self->{ver}, $command,
            @{$self}{qw(lang type api_key)}, $value );
    }
    else {
        $url->path_segments( $self->{ver}, $command,
            @{$self}{qw(lang type api_key)} );
        $url->query_form($params);
    }
    return $url->as_string();
}

sub new {
    my $class = shift;
    my ( %params ) = @_;

    croak "Required parameter api_key not provided." unless $params{api_key};
    if ( !defined $params{ua} ) {
        $params{ua} = LWP::UserAgent->new(
            agent  => "Perl-WWW-TMDB-API/$VERSION",
            Accept => 'application/json'
        );
    }
    else {
        croak "LWP::UserAgent expected." unless $params{ua}->isa('LWP::UserAgent');
    }

    my $self = {
        api_key => $params{api_key},
        ua      => $params{ua},
        lang    => 'en-US',
        type    => 'json',
        ver     => '2.1',
        url     => 'http://api.themoviedb.org',
    };

    bless $self, $class;
    return $self;
}

=head1 NAME

WWW::TMDB::API - TMDb API (http://api.themoviedb.org/2.1/) client

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

        use WWW::TMDB::API;

        # The constructor has 2 parameters - the api_key and the optional LWP::UserAgent object, ua.
        my $tmdb_client = WWW::TMDB::API->new( 'api_key' => 'your tmdb api key' );

        #  Retrieve specific information about the person with ID == 287
        $tmdb_client->person->info( ID => 287 );

        # Searches the themoviedb.org database for an actor, actress or production member with name 'Brad+Pitt'
        $tmdb_client->person->search( Name => 'Brad+Pitt' );

        # Searches the themoviedb.org database for an actor, actress or production member with name 'Brad'
        $tmdb_client->person->search( Name => 'Brad' );

        #  Search for a movie based on its IMDb ID.
        $tmdb_client->movie->imdb_lookup( 'IMDB ID' => 'tt0137523' );

        #  Determine the last movie created in the themoviedb.org database.
        $tmdb_client->movie->latest();

        #  Determine the last person(actor/actress/production member) created in the themoviedb.org database.
        $tmdb_client->person->latest();


=head1 DESCRIPTION

This module implements version 2.1 of the TMDb API. See L<http://api.themoviedb.org/2.1/> for the documentation.
The module uses the same parameter names used by the API.
The method names have been slightly changed. Here's the mapping of the method names used by this this module and the actual method names in the TMDb API:

    TMDb API             WWW::TMDB::API
    --------------       --------------------
    Media.getInfo        media->info()
    Movie.browse         movie->browse()
    Movie.getImages      movie->images()
    Movie.getInfo        movie->info()
    Movie.getLatest      movie->latest()
    Movie.getVersion     movie->version()
    Movie.imdbLookup     movie->imdb_lookup()
    Movie.search         movie->search()
    Person.getInfo       person->info()
    Person.getLatest     person->latest()
    Person.getVersion    person->version()
    Person.search        person->search()
    Genres.getList       misc->genres()


The API requires an API key which can be generated from http://api.themoviedb.org/2.1/.

This module converts the API output to Perl data structure using the module JSON.

This module does not support update methods, Media.addID and Movie.addRating.

=head1 SUBROUTINES/METHODS

=head2 new( %params )

Returns a new instance of the B<WWW::TMDB::API> class.

=over 4

=item * B<api_key>

Required. This is the TMDb API key. Go to the L<http://api.themoviedb.org/2.1/> to signup and generate an API key.

=item * B<ua>

Optional. The LWP::UserAgent used to communicate with the TMDb server.


        my $tmdb_client = WWW::TMDB::API->new( 'api_key' => 'your tmdb api key' );


        require LWP::UserAgent;
        $ua = LWP::UserAgent->new(
                'agent'        => "Perl-WWW-TMDB-API",
                'Accept'       => 'application/json',
                'Content-Type' => 'application/json',
        );

        my $tmdb_client =
                WWW::TMDB::API->new( 'api_key' => 'your tmdb api key', 'ua' => $ua );


=back

=head2 movie->browse( %params )

Queries the themoviedb.org database using a set of parameters/filters.

=over 4

=item * B<order_by>

Required. (3 options: rating, release, title)

=item * B<order>

Required. (2 options: asc, desc)

=item *  B<per_page>, B<page>, B<query>, B<min_votes>, B<rating_min>,B<rating_max>, B<genres>, B<genres_selector>, B<release_min>, 
B<release_max>, B<year>,  B<certifications>, B<companies>, B<countries>

Optional.

The Movie.browse documentation at L<http://api.themoviedb.org/2.1/methods/Movie.browse> describes the the parameters/filters in detail.

=back

        $result = $api->movie->browse(
           'query'    => 'Cool Hand Luke',
           'order_by' => 'title',
           'order'    => 'desc'
        );



=head2 movie->images( %params )

Searches the TMDb database for images that matches the given ID.

=over 4

=item * B<ID>

Required. The TMDb ID OR IMDB ID (starting with tt) of the movie. Retrieves all images(backdrops, posters) for a particular movie.

=back

        $result = $api->movie->images( 'ID' => 'tt0061512' );
        $result = $api->movie->images( 'ID' => 903 );

=head2  movie->info( %params )

Retrieves specific information about the movie that matches the given ID. 

=over 4

=item * B<ID>

Required. The TMDb ID of the movie.

=back

        $result = $api->movie->info( 'ID' => 903 );

=head2  movie->latest( )

Returns the TMDb ID of the last movie created in the themoviedb.org database.


=head2 movie->version( %params )

This method will be useful when checking for updates. Retrieves the last modified time and version number of the movie with the given ID.

=over 4

=item * B<ID>

Required. The TMDb ID of the movie. This field can contain the TMDb movie id (integer value), an IMDB ID, or a comma-separated list of IDs. The list of IDs can have a combination of TMDB and IMDB IDs.

=back

         $result = $api->movie->version( 'ID' => 'tt0061512,94744' );

=head2 movie->imdb_lookup( %params )

Searches the themoviedb.org database using the movie's IMDB ID.

=over 4

=item * B<IMDB ID>

Required. The IMDB ID of the movie.

=back
         $result = $api->movie->imdb_lookup( 'IMDB ID' => 'tt0061512' );

=head2  movie->search( %params )

Searches for movies that match the given Title. 

=over 4

=item * B<Title>

Required. The title of the movie. The title can include the year the movie was released (e.g. B<Transformers+2007>) to narrow the search results.

=back
         $result = $api->movie->search( 'Title' => 'Cool Hand' );

=head2  person->info( %params )

Retrieves specific information about the person that matches the given ID. 

=over 4

=item * B<ID>

Required. The TMDb ID of the person.

=back

         $result = $api->person->info( 'ID' => 3636 );

=head2  person->latest( )

Returns the ID of the last person created in the themoviedb.org database.

=head2 person->version( %params )

This method will be useful when checking for updates. Retrieves the last modified time and version number of the persion with the given ID.

=over 4

=item * B<ID>

Required. The TMDb ID of the person. 
This field supports an integer value (TMDb person id) or a comma-separated list of person IDs if you are searching for multiple people.

=back

         $result = $api->person->version( ID => 3636 );

=head2  person->search( %params )

Searches for actors, actresses, or production members that match the given Name. 

=over 4

=item * B<Name>

Required.

=back 

        $result = $api->person->search( 'Name' => 'Newman' );

=head2  misc->genres( )

Retrieves a list of valid genres within TMDb.

        $result = $api->misc->genres();

=head1 AUTHOR

Maria Celina Baratang, C<< <maria at zambale.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-tmdb-api at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-TMDB-API>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::TMDB::API


You can also look for information at:

=over 4

=item * TMDb The open movie database

L<http://themoviedb.org/>

=item * themoviedb.org API Documentation

L<http://api.themoviedb.org/2.1/>

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-TMDB-API>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-TMDB-API>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-TMDB-API>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-TMDB-API/>

=back


=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Maria Celina Baratang.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of WWW::TMDB::API


