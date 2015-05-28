use strict;
use warnings;

BEGIN {
    $ENV{DANCER_ENVIRONMENT} = 'test';
}

use D2::Ajax;
use Test::More tests => 3+1;
use Plack::Test;
use HTTP::Request::Common;
use Test::NoWarnings;
use JSON::MaybeXS qw(decode_json);
use MongoDB ();

subtest v2_greeting => sub {
    plan tests => 4;

    my $app = D2::Ajax->to_app;

    my $test = Plack::Test->create($app);
    my $res  = $test->request( GET '/api/v2/greeting' );

    ok $res->is_success, '[GET /] successful';
    is $res->content, '{"text":"Hello World"}';
    is $res->header('Content-Type'), 'application/json';
    is $res->header('Access-Control-Allow-Origin'), '*';
};

subtest v2_reverse => sub {
    plan tests => 6;

    my $app = D2::Ajax->to_app;

    my $test = Plack::Test->create($app);
    my $res  = $test->request( GET '/api/v2/reverse?str=Hello world' );

    ok $res->is_success, '[GET /] successful';
    is $res->content, '{"text":"dlrow olleH"}';
    is $res->header('Content-Type'), 'application/json';
    is $res->header('Access-Control-Allow-Origin'), '*';

    my $res2  = $test->request( GET '/api/v2/reverse?str=' );
    is $res2->content, '{"text":""}';

    my $res3  = $test->request( GET '/api/v2/reverse' );
    is $res3->content, '{"text":""}';
};

subtest v2_items => sub {
    plan tests => 6;

    my $app = D2::Ajax->to_app;

    my $db_name = 'd2-ajax-' . $$ . '-' . time;
    D2::Ajax->config->{app}{mongodb} = $db_name;

    my $test = Plack::Test->create($app);

    my $res  = $test->request( POST '/api/v2/item', {text => 'First Thing to do' } );
    ok $res->is_success, '[POST /] successful';
    is_deeply decode_json($res->content), { ok => 1, text  => 'First Thing to do' };
    is $res->header('Content-Type'), 'application/json';
    is $res->header('Access-Control-Allow-Origin'), '*';

    my $get1  = $test->request( GET '/api/v2/items');
    my $items1 = decode_json($get1->content);
    is scalar @{$items1->{items}}, 1;
    is $items1->{items}[0]{text}, 'First Thing to do';


    my $client = MongoDB::MongoClient->new(host => 'localhost', port => 27017);
    my $db   = $client->get_database( $db_name );
    $db->drop;
};

