package OpenAI::API::Resource::File::List;

use strict;
use warnings;

use Moo;
use strictures 2;
use namespace::clean;
use Types::Standard qw();

sub endpoint { 'files' }

1;

__END__

=head1 NAME

OpenAI::API::Resource::File::List - files endpoint

=head1 DESCRIPTION

Returns a list of files that belong to the user's organization.

=head1 METHODS

=head2 new()

=head1 SEE ALSO

OpenAI API Documentation: L<Files|https://platform.openai.com/docs/api-reference/files>