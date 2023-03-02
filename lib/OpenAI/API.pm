package OpenAI::API;

use strict;
use warnings;

use Carp qw/croak/;

use JSON::MaybeXS;
use LWP::UserAgent;

use OpenAI::API::Request::Completion;
use OpenAI::API::Request::Edit;
use OpenAI::API::Request::Embedding;
use OpenAI::API::Request::Moderation;

our $VERSION = 0.15;

sub new {
    my ( $class, %params ) = @_;
    my $self = {
        api_key  => $params{api_key} // $ENV{OPENAI_API_KEY},
        endpoint => $params{endpoint} || 'https://api.openai.com/v1',
    };

    croak 'Missing OPENAI_API_KEY' if !defined $self->{api_key};
    return bless $self, $class;
}

sub completions {
    my ( $self, %params ) = @_;
    my $request = OpenAI::API::Request::Completion->new( \%params );
    return $self->_post( 'completions', { %{$request} } );
}

sub edits {
    my ( $self, %params ) = @_;
    my $request = OpenAI::API::Request::Edit->new( \%params );
    return $self->_post( 'edits', { %{$request} } );
}

sub embeddings {
    my ( $self, %params ) = @_;
    my $request = OpenAI::API::Request::Embedding->new( \%params );
    return $self->_post( 'edits', { %{$request} } );
}

sub moderations {
    my ( $self, %params ) = @_;
    my $request = OpenAI::API::Request::Moderation->new( \%params );
    return $self->_post( 'moderations', { %{$request} } );
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

OpenAI::API - access GPT models via OpenAI API

=head1 SYNOPSIS

    use OpenAI::API;

    my $openai = OpenAI::API->new(); # uses OPENAI_API_KEY environment variable

    my $completions = $openai->completions(
        model  => 'text-davinci-003',
        prompt => 'What is the capital of France?',
    );

    my $edits = $openai->edits(
        model       => 'text-davinci-edit-001',
        input       => 'What day of the wek is it?',
        instruction => 'Fix the spelling mistakes',
    );

    my $moderations = $openai->moderations(
        model => 'text-moderation-latest',
        input => 'I want to kill them.',
    );

=head1 DESCRIPTION

OpenAI::API is a Perl module that provides an interface to the OpenAI API,
which allows you to generate text, translate languages, summarize text,
and perform other tasks using the language models developed by OpenAI.

To use the OpenAI::API module, you will need an API key, which you can obtain by
signing up for an account on the L<OpenAI website|https://platform.openai.com>.

=head1 METHODS

=head2 new()

Creates a new OpenAI::API object.

=over 4

=item * api_key [optional]

Your API key. Default: C<$ENV{OPENAI_API_KEY}>.

Attention: never commit API keys to your repository. Use the C<OPENAI_API_KEY>
environment variable instead.

See: L<Best Practices for API Key Safety|https://help.openai.com/en/articles/5112595-best-practices-for-api-key-safety>.

=item * endpoint [optional]

The endpoint URL for the OpenAI API. Default: 'https://api.openai.com/v1/'.

=back

=head2 completions()

Given a prompt, the model will return one or more predicted completions.

Mandatory parameters:

=over 4

=item * model

ID of the model to use.

=item * prompt

The prompt for the text generation.

=back

More info: L<OpenAI::API::Request::Completion>

=head2 edits()

Creates a new edit for the provided input, instruction, and parameters.

Mandatory parameters:

=over 4

=item * model

ID of the model to use. You can use the text-davinci-edit-001 or
code-davinci-edit-001 model with this endpoint.

=item * instruction

The instruction that tells the model how to edit the prompt.

=item * input [optional, but often required]

The input text to use as a starting point for the edit.

=back

More info: L<OpenAI::API::Request::Edit>

=head2 embeddings()

Get a vector representation of a given input that can be easily consumed
by machine learning models and algorithms.

=over 4

=item * model

=item * input

=back

More info: L<OpenAI::API::Request::Embedding>

=head2 moderations()

Given a input text, outputs if the model classifies it as violating
OpenAI's content policy.

Mandatory parameters:

=over 4

=item * input

=back

Documentation: L<Moderations|https://platform.openai.com/docs/api-reference/moderations>

=head1 SEE ALSO

L<OpenAI Reference Overview|https://platform.openai.com/docs/api-reference/overview>

=head1 AUTHOR

Nelson Ferraz E<lt>nferraz@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022, 2023 by Nelson Ferraz

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.30.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
