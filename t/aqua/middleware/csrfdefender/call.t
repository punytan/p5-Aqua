use sane;
use Test::More;

use LWP::UserAgent;
use LWP::Protocol::PSGI;

use Plack::Request;
use Plack::Session;
use Plack::Middleware::Session;

use Aqua::Middleware::CSRFDefender;

my $raw_app = sub {
    my $env = shift;
    my $ses = Plack::Session->new($env);
    my $req = Plack::Request->new($env);
    my $res = $req->new_response(200);
    $res->body( $ses->get("csrf_token") );
    return $res->finalize;
};

my $url = "http://localhost/";

my $error_message = 'oops';

subtest "Should not work without session middleware" => sub {
    my $app = Aqua::Middleware::CSRFDefender->wrap($raw_app);
    my $guard = LWP::Protocol::PSGI->register($app);

    my $res = LWP::UserAgent->new->get($url);
    is $res->code, 500;
};

subtest "Basic test cases" => sub {
    # Prepare environments for testing
    my $app = Plack::Middleware::Session->wrap(
        Aqua::Middleware::CSRFDefender->wrap($raw_app, error_message => $error_message)
    );

    my $guard = LWP::Protocol::PSGI->register($app);
    my $ua = LWP::UserAgent->new( cookie_jar => {} );

    my $token = $ua->get($url)->content;

    subtest "returns the same token for the same client" => sub {
        my $res = $ua->get($url);
        is $res->code, 200;
        is $res->content, $token;
    };

    subtest "returns different token for another client" => sub {
        my $another_token = LWP::UserAgent->new->get($url)->content;
        isnt $another_token, $token;
    };

    subtest "post with valid token" => sub {
        my $res = $ua->post($url, [csrf_token => $token]);
        is $res->code, 200;
        is $res->content, $token;
    };

    subtest "post with invalid token" => sub {
        my $res = $ua->post($url, [csrf_token => 'invalid token']);
        is $res->code, 403;
        is $res->content, $error_message;
    };

    subtest "post without token" => sub {
        my $res = LWP::UserAgent->new->post($url);
        is $res->code, 403;
        is $res->content, $error_message;
    };

};

done_testing;


