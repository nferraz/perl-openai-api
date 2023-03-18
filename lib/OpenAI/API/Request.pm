package OpenAI::API::Request;

use AnyEvent;
use JSON::MaybeXS;
use LWP::UserAgent;
use Promises qw/deferred/;

use Moo;
use strictures 2;
use namespace::clean;

use OpenAI::API;

sub endpoint {
    die "Must be implemented";
}

sub method {
    die "Must be implemented";
}

sub send {
    my ( $self, $api ) = @_;

    $api //= OpenAI::API->new();

    return
          $self->method eq 'POST' ? $self->_post($api)
        : $self->method eq 'GET'  ? $self->_get($api)
        :                           die "Invalid method";
}

sub _get {
    my ( $self, $api ) = @_;

    my $req = $self->_create_request( $api, 'GET' );
    return $self->_send_request( $api, $req );
}

sub _post {
    my ( $self, $api ) = @_;

    my $req = $self->_create_request( $api, 'POST', encode_json( { %{$self} } ) );
    return $self->_send_request( $api, $req );
}

sub send_async {
    my ( $self, $api ) = @_;

    $api //= OpenAI::API->new();

    return
          $self->method eq 'POST' ? $self->_post_async($api)
        : $self->method eq 'GET'  ? $self->_get_async($api)
        :                           die "Invalid method";
}

sub _get_async {
    my ( $self, $api ) = @_;

    my $req = $self->_create_request( $api, 'GET' );
    return $self->_send_request_async( $api, $req );
}

sub _post_async {
    my ( $self, $api ) = @_;

    my $req = $self->_create_request( $api, 'POST', encode_json( { %{$self} } ) );
    return $self->_send_request_async( $api, $req );
}

sub _create_request {
    my ( $self, $api, $method, $content ) = @_;

    my $endpoint = $self->endpoint();
    my $req      = HTTP::Request->new(
        $method => "$api->{api_base}/$endpoint",
        $self->_request_headers($api),
        $content,
    );

    return $req;
}

sub _request_headers {
    my ( $self, $api ) = @_;

    return [
        'Content-Type'  => 'application/json',
        'Authorization' => "Bearer $api->{api_key}",
    ];
}

sub _send_request {
    my ( $self, $api, $req ) = @_;

    my $cond_var = AnyEvent->condvar;

    $self->_async_http_send_request( $api, $req )->then(
        sub {
            $cond_var->send(@_);
        }
    )->catch(
        sub {
            $cond_var->send(@_);
        }
    );

    my $res = $cond_var->recv();

    if ( !$res->is_success ) {
        die "Error: '@{[ $res->status_line ]}'";
    }

    return decode_json( $res->decoded_content );
}

sub _send_request_async {
    my ( $self, $api, $req ) = @_;

    return $self->_async_http_send_request( $api, $req )->then(
        sub {
            my $res = shift;

            if ( !$res->is_success ) {
                die "Error: '@{[ $res->status_line ]}'";
            }

            return decode_json( $res->decoded_content );
        }
    )->catch(
        sub {
            my $err = shift;
            die $err;
        }
    );
}

sub _http_send_request {
    my ( $self, $api, $req ) = @_;

    for my $attempt ( 1 .. $api->{retry} ) {
        my $res = $api->user_agent->request($req);

        if ( $res->is_success ) {
            return $res;
        } elsif ( $res->code =~ /^(?:500|503|504|599)$/ && $attempt < $api->{retry} ) {
            sleep( $api->{sleep} );
        } else {
            return $res;
        }
    }
}

sub _async_http_send_request {
    my ( $self, $api, $req ) = @_;

    my $d = deferred;

    AnyEvent::postpone {
        eval {
            my $res = $self->_http_send_request( $api, $req );
            $d->resolve($res);
            1;
        } or do {
            my $err = $@;
            $d->reject($err);
        };
    };

    return $d->promise();
}

1;

__END__

=head1 NAME

OpenAI::API::Request - Base module for making requests to the OpenAI API

=head1 SYNOPSIS

This module is a base module for making HTTP requests to the OpenAI
API. It should not be used directly.

=head1 DESCRIPTION

This module provides a base class for creating request objects for the
OpenAI API. It includes methods for sending synchronous and asynchronous
requests, with support for HTTP GET and POST methods.

=head1 METHODS

=head2 endpoint

This method must be implemented by subclasses. It should return the API
endpoint for the specific request.

=head2 method

This method must be implemented by subclasses. It should return the HTTP
method for the specific request.

=head2 send

    my $response = $request->send($api);

Send a request synchronously. The C<$api> parameter is optional; if not
provided, a new L<OpenAI::API> object will be created.

=head2 send_async

Send a request asynchronously. The C<$api> parameter is optional; if
not provided, a new L<OpenAI::API> object will be created. Returns a
L<Promises> promise that will be resolved with the decoded JSON response.

Here's an example usage:

    my $cv = AnyEvent->condvar;    # Create a condition variable

    $request->send_async()->then(
        sub {
            my $response_data = shift;
            print "Response data: " . Dumper($response_data);
        }
    )->catch(
        sub {
            my $error = shift;
            print "$error\n";
        }
    )->finally(
        sub {
            print "Request completed\n";
            $cv->send();    # Signal the condition variable when the request is completed
        }
    );

    $cv->recv;              # Keep the script running until the request is completed.

=head1 SEE ALSO

L<OpenAI::API>
