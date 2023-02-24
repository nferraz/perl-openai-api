#!perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use OpenAI::API;

# force authentication error
$ENV{OPENAI_API_KEY} = '';

my $openai = OpenAI::API->new();

my @test_cases = (
    {
        method    => 'completions',
        params    => { model => '', prompt => '' },
        exception => qr/401 Unauthorized/,
    },
    {
        method    => 'edits',
        params    => { model => '', instruction => '' },
        exception => qr/401 Unauthorized/,
    },
    {
        method    => 'embeddings',
        params    => { model => '', input => '' },
        exception => qr/401 Unauthorized/,
    },
    {
        method    => 'moderations',
        params    => { input => '' },
        exception => qr/401 Unauthorized/,
    },
);

for my $test (@test_cases) {
    my ( $method, $params, $exception ) = @{$test}{qw/method params exception/};

    throws_ok { my $response = $openai->$method( %{$params} ); } $exception;
}

done_testing();
