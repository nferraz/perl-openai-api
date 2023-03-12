package OpenAI::API::Resource::Model::Retrieve;

use strict;
use warnings;

use Types::Standard qw(Str);

use Moo;
use strictures 2;
use namespace::clean;

extends 'OpenAI::API::Resource';

has model => ( is => 'ro', isa => Str, required => 1 );

sub endpoint {
    my ($self) = @_;
    return 'models/' . $self->{model};
}

sub method { 'GET' }

1;

__END__

=head1 NAME

OpenAI::API::Resource::Model::Retrieve - retrieve model details

=head1 DESCRIPTION

Retrieves a model instance, providing basic information about the model
such as the owner and permissioning.

=head1 METHODS

=head2 new()

=over

=item model

=back

=head1 SEE ALSO

OpenAI API Documentation: L<Models|https://platform.openai.com/docs/api-reference/models>
