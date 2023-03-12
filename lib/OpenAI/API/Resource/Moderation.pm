package OpenAI::API::Resource::Moderation;

use strict;
use warnings;

use Moo;
use strictures 2;
use namespace::clean;

extends 'OpenAI::API::Resource';

use Types::Standard qw(Bool Str Num Int Map);

has input => ( is => 'rw', isa => Str, required => 1, );

has model => ( is => 'rw', isa => Str, );

sub endpoint { 'moderations' }
sub method   { 'POST' }

1;

__END__

=head1 NAME

OpenAI::API::Resource::Moderation - moderations endpoint

=head1 SYNOPSIS

    use OpenAI::API;
    use OpenAI::API::Resource::Moderation;

    my $api = OpenAI::API->new();

    my $request = OpenAI::API::Resource::Moderation->new(
        input => "I like turtles",
    );

    my $res = $request->dispatch($api);

=head1 DESCRIPTION

Given a input text, outputs if the model classifies it as violating
OpenAI's content policy.

=head1 METHODS

=head2 new()

=over 4

=item * input

=item * model [optional]

=back

=head1 SEE ALSO

OpenAI API Documentation: L<Moderations|https://platform.openai.com/docs/api-reference/moderations>
