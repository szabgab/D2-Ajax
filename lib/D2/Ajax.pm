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

true;
