use sane;
use Test::More;

use LWP::UserAgent;
use LWP::Protocol::PSGI;

use Aqua;
use t::App::Router;

my $router = t::App::Router->register;

subtest "app without session" => sub {

    my $aqua = Aqua->new(router => $router);
    $aqua->load_controllers;

    my $app = $aqua->wrap_default_middlewares($aqua->raw_app, { Session => undef });

    my $gurad = LWP::Protocol::PSGI->register($app);

    my $ua = LWP::UserAgent->new( cookie_jar => {} );

    subtest "GET /" => sub {
        my $res = $ua->get("http://localhost/");
        is $res->headers->content_length, 4;
        is $res->content, 'root';
    };

    subtest "GET /not_found" => sub {
        my $res = $ua->get("http://localhost/not_found");
        is $res->code, 404;
        is $res->content, 'Not Found';
    };

    subtest "POST /" => sub {
        my $res = $ua->post("http://localhost/");
        is $res->code, 405;
        is $res->content, 'Method Not Allowed';
    };

    subtest "GET /login" => sub {
        my $res = $ua->get("http://localhost/login");
        is $res->code, 200;
        is $res->content, "/login\n";
    };

};

done_testing;

