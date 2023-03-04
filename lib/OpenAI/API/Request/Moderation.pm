package OpenAI::API::Request::Moderation;

use strict;
use warnings;

use Moo;
use strictures 2;
use namespace::clean;
use Types::Standard qw(Bool Str Num Int Map);

has input => ( is => 'rw', isa => Str, required => 1, );

has model => ( is => 'rw', isa => Str, );
has timeout => ( is => 'rw', isa => Int, );

1;

__END__

=head1 NAME

OpenAI::API::Request::Moderation - moderations endpoint

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
