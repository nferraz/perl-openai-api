package OpenAI::API::Request::Audio;

use strict;
use warnings;

use Carp qw/croak/;

use Moo;
use strictures 2;
use namespace::clean;

extends 'OpenAI::API::Request';

use Types::Standard qw(Any Bool Int Num Str Map ArrayRef HashRef);

has model => ( is => 'rw', isa => Str, default => 'whisper-1' );

has file	          => ( is => 'rw', isa => Str, );
has prompt            => ( is => 'rw', isa => Str, );
has response_format   => ( is => 'rw', isa => Str, );
has temperature       => ( is => 'rw', isa => Num, );

sub endpoint { 'audio/transcriptions' }
sub method   { 'POST' }

sub _request_headers {
    my ($self) = @_;

    return [
        'Content-Type'  => 'multipart/form-data',
        'Authorization' => 'Bearer ' . $self->config->api_key,
    ];
}

around send => sub {
    my $orig = shift;
    my $self = shift;
    my %args = @_;
    $args{'http_response'} = 1;
    
    # Call the original method
    my $res = $self->$orig(%args); 
    return $res->decoded_content;
};


sub _post {
    my ($self) = @_;

	my $params =  $self->request_params();

	# Add the file to the request body
	open my $file, '<', $params->{'file'} or die "Could not open file: $!";
	binmode $file;
	my $fileData = do { local $/; <$file> };	
	close $file;
		
    $params->{'file'} = [ $params->{'file'} ];

	# Use alternative library to build a request with the file included.
	use HTTP::Request::Common;

	my $req = HTTP::Request::Common::POST( $self->config->api_base . '/' . $self->endpoint,
			 Content_Type => 'form-data',
			 Authorization => 'Bearer ' . $self->config->api_key,
			 Content      => $params
		 );

    return $self->_send_request($req);
}

1;

__END__

=head1 NAME

OpenAI::API::Request::Audio - Request class for OpenAI API Whisper audio transcription

=head1 SYNOPSIS

    use OpenAI::API::Request::Audio;

    my $transcript = OpenAI::API::Request::Audio->new(
        file => $fileData,
        prompt => 'A transcription for Little Hills Church's sermon podcast.',
        response_format => 'text'
    );

    my $message	= $transcript->send();    

=head1 DESCRIPTION

This module provides a request class for interacting with the OpenAI API's
transcription endpoint. It inherits from L<OpenAI::API::Request>.

=head1 ATTRIBUTES

=head2 model

ID of the model to use.

See L<Models overview|https://platform.openai.com/docs/models/overview>
for a reference of them.

=head2 messages

The messages to generate chat completions for, in the L<chat
format|https://platform.openai.com/docs/guides/chat/introduction>.

=head2 max_tokens [optional]

The maximum number of tokens to generate.

Most models have a context length of 2048 tokens (except for the newest
models, which support 4096).

=head2 temperature [optional]

What sampling temperature to use, between 0 and 2. Higher values like
0.8 will make the output more random, while lower values like 0.2 will
make it more focused and deterministic.

=head2 top_p [optional]

An alternative to sampling with temperature, called nucleus sampling.

We generally recommend altering this or C<temperature> but not both.

=head2 n [optional]

How many completions to generate for each prompt.

Use carefully and ensure that you have reasonable settings for
C<max_tokens> and C<stop>.

=head2 stop [optional]

Up to 4 sequences where the API will stop generating further tokens. The
returned text will not contain the stop sequence.

=head2 frequency_penalty [optional]

Number between -2.0 and 2.0. Positive values penalize new tokens based
on their existing frequency in the text so far.

=head2 presence_penalty [optional]

Number between -2.0 and 2.0. Positive values penalize new tokens based
on whether they appear in the text so far.

=head2 user [optional]

A unique identifier representing your end-user, which can help OpenAI
to monitor and detect abuse.


=head1 INHERITED METHODS

This module inherits the following methods from L<OpenAI::API::Request>:

=head2 send(%args)

=head2 send_async(%args)

=head1 SEE ALSO

L<OpenAI::API::Request>, L<OpenAI::API::Config>