package OpenAI::API::ResourceDispatcherRole;

use Moo::Role;
use strictures 2;
use namespace::clean;

my %module_dispatcher = (
    chat           => 'OpenAI::API::Resource::Chat',
    completions    => 'OpenAI::API::Resource::Completion',
    edits          => 'OpenAI::API::Resource::Edit',
    embeddings     => 'OpenAI::API::Resource::Embedding',
    files          => 'OpenAI::API::Resource::File::List',
    file_retrieve  => 'OpenAI::API::Resource::File::Retrieve',
    image_create   => 'OpenAI::API::Resource::Image::Generation',
    models         => 'OpenAI::API::Resource::Model::List',
    model_retrieve => 'OpenAI::API::Resource::Model::Retrieve',
    moderations    => 'OpenAI::API::Resource::Moderation',
);

for my $sub_name ( keys %module_dispatcher ) {
    my $module = $module_dispatcher{$sub_name};

    eval "require $module";

    no strict 'refs';
    *{"OpenAI::API::ResourceDispatcherRole::$sub_name"} = sub {
        my ( $self, %params ) = @_;
        my $request = $module->new( \%params );
        return $request->dispatch($self);
    };
}

1;
