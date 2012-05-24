use sane;
use Test::More;

use LWP::UserAgent;
use LWP::Protocol::PSGI;

use Aqua::Application;
use t::App::Router;

subtest "static middleware" => sub {
    my $router = t::App::Router->register;
    my $app = Aqua::Application->new(router => $router)->to_app;

    my $gurad = LWP::Protocol::PSGI->register($app);

    my $ua = LWP::UserAgent->new( cookie_jar => {} );

    subtest "get /" => sub {
        my $res = $ua->get("http://localhost/");
        is $res->headers->content_length, 4;
        is $res->content, 'root';
    };

    subtest "get javascript from static path" => sub {
        my $res = $ua->get("http://localhost/static/js/my.js");
        is $res->code, 200;
        is $res->headers->header("content_type"),
            'application/javascript';
    };

    subtest "get css from static path" => sub {
        my $res = $ua->get("http://localhost/static/css/my.css");
        is $res->code, 200;
        is $res->headers->header("content_type"),
            'text/css; charset=utf-8';
    };

    subtest "don't allow directory traversal" => sub {
        my $res = $ua->get("http://localhost/static/../app.psgi");
        is $res->code, 403;
        is $res->content, "forbidden";
    };

    subtest "don't allow directory traversal - encoding pattern" => sub {
        my $res = $ua->get("http://localhost/static/%2e%2e%2fapp.psgi");
        is $res->code, 403;
        is $res->content, "forbidden";
    };

};

done_testing;

