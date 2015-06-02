package D2::Ajax;
use Dancer2;
use MongoDB ();
use JSON::MaybeXS;

our $VERSION = '0.1';

sub _mongodb {
    my ($collection) = @_;

    my $client = MongoDB::MongoClient->new(host => 'localhost', port => 27017);
    my $db   = $client->get_database( config->{app}{mongodb} );
    return $db->get_collection($collection);
}

hook before => sub {
    if (request->path =~ m{^/api/}) {
        header 'Content-Type' => 'application/json';
    }
    if (request->path =~ m{^/api/v2/}) {
        header 'Access-Control-Allow-Origin' => '*';
    }
};

get '/' => sub {
    template 'index';
};

get '/api/v1/greeting' => sub {
    return to_json { text => 'Hello World' };
};

get '/v1' => sub {
    return template 'v1';
};

get '/api/v2/greeting' => sub {
    return to_json { text => 'Hello World' };
};

get '/api/v2/reverse' => sub {
    my $text = param('str') // '';
    my $rev = reverse $text;
    return to_json { text => $rev };
};

post '/api/v2/item' => sub {
    my $text = param('text') // '';
    $text =~ s/^\s+|\s+$//g;
    if ($text eq '') {
        return to_json { error => 'No text provided' };
    }

    my $items = _mongodb('items');
    $items->insert({
        text => $text,
    });
    return to_json { ok => 1, text => $text };
};

get '/api/v2/items' => sub {
    my $items = _mongodb('items');
    my @data =  $items->find->all;
    my $json = JSON::MaybeXS->new;
    $json->convert_blessed(1);
    return $json->encode( { items =>  \@data } );
};


true;

