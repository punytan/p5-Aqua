use sane;
use Test::More;
use Plack::Test;

use LWP::UserAgent;
use LWP::Protocol::PSGI;

use Aqua;
use t::App::Router;

isa_ok( Aqua->new(), "Aqua" );

subtest "ordinary app" => sub {

    my $app = Aqua->new->to_app;
    my $gurad = LWP::Protocol::PSGI->register($app);

    my $ua = LWP::UserAgent->new( cookie_jar => {} );
    my $token = $ua->get("http://localhost/token")->content;

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
        is $res->code, 403;
        is $res->content, 'Forbidden';
    };

    subtest "POST / with token" => sub {
        my $res = $ua->post("http://localhost/", [csrf_token => $token]);
        is $res->code, 405;
        is $res->content, 'Method Not Allowed';
    };

    subtest "GET /login" => sub {
        my $res = $ua->get("http://localhost/login");
        is $res->code, 200;
        is $res->content, "/login\n";
    };

    subtest "POST /login" => sub {
        my $res = $ua->post("http://localhost/login", [csrf_token => $token]);
        is $res->code, 200;
        is $res->content, "OK";
    };

};

done_testing;