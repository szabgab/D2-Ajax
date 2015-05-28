use strict;
use warnings;

BEGIN {
    $ENV{DANCER_ENVIRONMENT} = 'test';
}


use D2::Ajax;
use Test::More tests => 1;
use Plack::Test;
use HTTP::Request::Common;

subtest v1_greeting => sub {
    plan tests => 4;

    my $app = D2::Ajax->to_app;

    my $test = Plack::Test->create($app);
    my $res  = $test->request( GET '/api/v1/greeting' );

    ok $res->is_success, '[GET /] successful';
    is $res->content, '{"text":"Hello World"}';
    is $res->header('Content-Type'), 'application/json';
    is $res->header('Access-Control-Allow-Origin'), undef;
};
