package OpenAI::API;

use strict;
use warnings;
use LWP::UserAgent;
use JSON::MaybeXS;

our $VERSION = 0.08;

sub new {
    my ( $class, %params ) = @_;
    my $self = {
        api_key  => $params{api_key} // $ENV{OPENAI_API_KEY},
        endpoint => $params{endpoint} || 'https://api.openai.com/v1',
    };
    return bless $self, $class;
}

sub completions {
    my ( $self, %params ) = @_;
    return $self->_post( 'completions', \%params );
}

sub edits {
    my ( $self, %params ) = @_;
    return $self->_post( 'edits', \%params );
}

sub embeddings {
    my ( $self, %params ) = @_;
    return $self->_post( 'embeddings', \%params );
}

sub moderations {
    my ( $self, %params ) = @_;
    return $self->_post( 'moderations', \%params );
}

sub _post {
    my ( $self, $method, $params ) = @_;

    my $ua = LWP::UserAgent->new();

    my $req = HTTP::Request->new(
        POST => "$self->{endpoint}/$method",
        [
            'Content-Type'  => 'application/json',
            'Authorization' => "Bearer $self->{api_key}",
        ],
        encode_json($params),
    );

    my $res = $ua->request($req);

    if ( $res->is_success ) {
        return decode_json( $res->decoded_content );
    } else {
        die "Error retrieving '$method': " . $res->status_line;
    }
}

1;

__END__

=head1 NAME

OpenAI::API - A Perl module for accessing the OpenAI API

=head1 SYNOPSIS

    use OpenAI::API;

    my $openai = OpenAI::API->new( api_key => 'YOUR_API_KEY' );

    my $response = $openai->completions(
        model             => 'text-davinci-003',
        prompt            => 'What is the capital of France?',
        max_tokens        => 2048,
        temperature       => 0.5,
        top_p             => 1,
        frequency_penalty => 0,
        presence_penalty  => 0
    );

=head1 DESCRIPTION

OpenAI::API is a Perl module that provides an interface to the OpenAI API,
which allows you to generate text, translate languages, summarize text,
and perform other tasks using the language models developed by OpenAI.

To use the OpenAI::API module, you will need an API key, which you can obtain by
signing up for an account on the L<OpenAI website|https://openai.com>.

=head1 METHODS

=head2 new()

Creates a new OpenAI::API object.

=over 4

=item api_key (optional)

Your API key. Default: C<$ENV{OPENAI_API_KEY}>.

Attention: never commit API keys to your repository. Use the C<OPENAI_API_KEY>
environment variable instead.

See: L<Best Practices for API Key Safety|https://help.openai.com/en/articles/5112595-best-practices-for-api-key-safety>.

=item endpoint (optional)

The endpoint URL for the OpenAI API. Default: 'https://api.openai.com/v1/'.

=back

=head2 completions()

Given a prompt, the model will return one or more predicted completions.

Documentation: L<Completions|https://beta.openai.com/docs/api-reference/completions>

=over 4

=item model

The name of the language model to use.

See 'https://beta.openai.com/docs/api-reference/models'.

=item prompt

The prompt for the text generation.

=item max_tokens (optional)

The maximum number of tokens to generate.

=item temperature (optional)

The temperature to use for sampling.

=item top_p (optional)

The top-p value to use for sampling.

=item frequency_penalty (optional)

The frequency penalty to use for sampling.

=item presence_penalty (optional)

The presence penalty to use for sampling.

=back

=head2 edits()

Creates a new edit for the provided input, instruction, and parameters.

Documentation: L<Edits|https://platform.openai.com/docs/api-reference/edits>

=head2 embeddings()

Get a vector representation of a given input that can be easily consumed by machine learning models and algorithms.

Documentation: L<Embeddings|https://platform.openai.com/docs/api-reference/embeddings>

=head2 moderations()

Given a input text, outputs if the model classifies it as violating OpenAI's content policy.

Documentation: L<Moderations|https://platform.openai.com/docs/api-reference/moderations>

=head1 SEE ALSO

L<OpenAI Reference Overview|https://beta.openai.com/docs/api-reference/overview>

=head1 AUTHOR

Nelson Ferraz <lt>nferraz@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022, 2023 by Nelson Ferraz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.30.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
