package D2::Ajax;
use Dancer2;

our $VERSION = '0.1';

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
    my $text = param('str');
    my $rev = reverse $text;
    return to_json { text => $rev };
};


true;
