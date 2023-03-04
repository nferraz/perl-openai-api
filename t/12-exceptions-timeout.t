#!perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::RequiresInternet;

use OpenAI::API;

my $openai = OpenAI::API->new( timeout => 0.01 );

my @test_cases = (
    {
        method    => 'completions',
        params    => { model => 'text-davinci-003', prompt => 'How would you explain the idea of justice?' },
        exception => qr/Operation timed out/,
    },
);

for my $test (@test_cases) {
    my ( $method, $params, $exception ) = @{$test}{qw/method params exception/};

    throws_ok { my $response = $openai->$method( %{$params} ); } $exception;
}

done_testing();
