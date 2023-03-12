package OpenAI::API::ResourceDispatcherRole;

use OpenAI::API::Resource::Chat;
use OpenAI::API::Resource::Completion;
use OpenAI::API::Resource::Edit;
use OpenAI::API::Resource::Embedding;
use OpenAI::API::Resource::File::List;
use OpenAI::API::Resource::File::Retrieve;
use OpenAI::API::Resource::Image::Generation;
use OpenAI::API::Resource::Model::List;
use OpenAI::API::Resource::Model::Retrieve;
use OpenAI::API::Resource::Moderation;

use Moo::Role;
use strictures 2;
use namespace::clean;

sub chat {
    my ( $self, %params ) = @_;
    my $request = OpenAI::API::Resource::Chat->new( \%params );
    return $request->dispatch($self);
}

sub completions {
    my ( $self, %params ) = @_;
    my $request = OpenAI::API::Resource::Completion->new( \%params );
    return $request->dispatch($self);
}

sub edits {
    my ( $self, %params ) = @_;
    my $request = OpenAI::API::Resource::Edit->new( \%params );
    return $request->dispatch($self);
}

sub embeddings {
    my ( $self, %params ) = @_;
    my $request = OpenAI::API::Resource::Embedding->new( \%params );
    return $request->dispatch($self);
}

sub files {
    my ( $self, %params ) = @_;
    my $request = OpenAI::API::Resource::File::List->new( \%params );
    return $request->dispatch($self);
}

sub file_retrieve {
    my ( $self, %params ) = @_;
    my $request = OpenAI::API::Resource::File::Retrieve->new( \%params );
    return $request->dispatch($self);
}

sub image_create {
    my ( $self, %params ) = @_;
    my $request = OpenAI::API::Resource::Image::Generation->new( \%params );
    return $request->dispatch($self);
}

sub moderations {
    my ( $self, %params ) = @_;
    my $request = OpenAI::API::Resource::Moderation->new( \%params );
    return $request->dispatch($self);
}

sub models {
    my ( $self, %params ) = @_;
    my $request = OpenAI::API::Resource::Model::List->new( \%params );
    return $request->dispatch($self);
}

sub model_retrieve {
    my ( $self, %params ) = @_;
    my $request = OpenAI::API::Resource::Model::Retrieve->new( \%params );
    return $request->dispatch($self);
}

1;
