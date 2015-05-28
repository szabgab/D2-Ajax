package D2::Ajax;
use Dancer2;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/api/v1/greeting' => sub {
    header 'Content-Type' => 'application/json';
    return to_json { text => 'Hello World' };
};

get '/v1' => sub {
    return template 'v1';
};

get '/api/v2/greeting' => sub {
    header 'Access-Control-Allow-Origin' => '*';
    header 'Content-Type' => 'application/json';
    return to_json { text => 'Hello World' };
};

get '/api/v2/reverse' => sub {
    header 'Access-Control-Allow-Origin' => '*';
    header 'Content-Type' => 'application/json';
    my $text = param('str');
    my $rev = reverse $text;
    return to_json { text => $rev };
};


true;
