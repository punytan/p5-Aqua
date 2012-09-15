use sane;
use Test::More;

use LWP::UserAgent;
use LWP::Protocol::PSGI;

use Aqua::Middleware::ErrorDocument;
use FindBin;

my $url = "http://localhost/";

subtest "has content" => sub {
    my $app = Aqua::Middleware::ErrorDocument->wrap(
        sub { [200, ["Content-Type" => "text/plain"], ["OK"]] }
    );
    my $guard = LWP::Protocol::PSGI->register($app);

    my $res = LWP::UserAgent->new->get($url);
    is $res->code, 200;
    is $res->headers->content_type, "text/plain";
    is $res->content, "OK";
};

subtest "automatically appends body" => sub {
    my $app = Aqua::Middleware::ErrorDocument->wrap(
        sub { [404 , ["Content-Type" => "text/plain"], []] }
    );
    my $guard = LWP::Protocol::PSGI->register($app);

    my $res = LWP::UserAgent->new->get($url);
    is $res->code, 404;
    is $res->headers->content_type, "text/plain";
    is $res->content, "Not Found"
};

subtest "has static errordoc" => sub {
    my $app = Aqua::Middleware::ErrorDocument->wrap(
        sub { [500, [], []] }
    );
    my $guard = LWP::Protocol::PSGI->register($app);

    my $res = LWP::UserAgent->new->get($url);
    is $res->code, 500;
    is $res->header("Content-Type"), "text/html; charset=UTF-8";

    open my $fh, "<", "$FindBin::Bin/errordoc/500" or die $!;
    is $res->content, do { local $/; <$fh> };
};

done_testing;

