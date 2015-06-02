use strict;
use warnings;

BEGIN {
    $ENV{DANCER_ENVIRONMENT} = 'test';
}

use D2::Ajax;
use Test::More tests => 3+1;
use Plack::Test;
use HTTP::Request::Common qw(GET POST DELETE);
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
    plan tests => 25;

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

    my $res2  = $test->request( POST '/api/v2/item', { text => '' } );
    is $res2->content, '{"error":"No text provided"}';

    my $res3  = $test->request( POST '/api/v2/item' );
    is $res3->content, '{"error":"No text provided"}';

    my $get3  = $test->request( GET '/api/v2/items');
    my $items3 = decode_json($get3->content);
    is scalar @{$items3->{items}}, 1;
    is $items3->{items}[0]{text}, 'First Thing to do';

    my $res4  = $test->request( POST '/api/v2/item', { text => '  one more  ' });
    is_deeply decode_json($res4->content), { ok => 1, text => 'one more' };

    my $get4  = $test->request( GET '/api/v2/items');
    my $items4 = decode_json($get4->content);
    is scalar @{$items4->{items}}, 2;
    is $items4->{items}[0]{text}, 'First Thing to do';
    is $items4->{items}[1]{text}, 'one more';

    my @items = ("One 1", "Two 2", "Three 3");
    foreach my $it (@items) {
        my $res = $test->request( POST '/api/v2/item', { text => $it });
        is_deeply decode_json($res->content), { ok => 1, text => $it };
    }
    my $get5  = $test->request( GET '/api/v2/items');
    my $items5 = decode_json($get5->content);
    is scalar @{$items5->{items}}, 5;

    my $del3  = $test->request( DELETE '/api/v2/item/' . $items5->{items}[3]{'_id'}{'$oid'} );
    is $del3->content, '{"ok":1}';

    my $get6  = $test->request( GET '/api/v2/items');
    my $items6 = decode_json($get6->content);
    is scalar @{$items6->{items}}, 4;
    is_deeply $items5->{items}[0], $items6->{items}[0];
    is_deeply $items5->{items}[1], $items6->{items}[1];
    is_deeply $items5->{items}[2], $items6->{items}[2];
    is_deeply $items5->{items}[4], $items6->{items}[3];
    is_deeply $items5->{items}[5], $items6->{items}[4];

    my $client = MongoDB::MongoClient->new(host => 'localhost', port => 27017);
    my $db   = $client->get_database( $db_name );
    $db->drop;
};

