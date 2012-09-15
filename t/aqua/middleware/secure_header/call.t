use sane;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use Aqua::Middleware::SecureHeader;

my @items = (
    {
        params => {
            'X-XSS-Protection' => "1; mode=block",
            'X-Frame-Options'  => "DENY",
            'X-Content-Type-Options' => "nosniff",
        },
    },
    {
        params => {
            'X-Content-Type-Options' => "nosniff",
        },
    },
    {
        params => { },
    },
);

my @allowed_headers = qw(
    X-XSS-Protection
    X-Frame-Options
    X-Content-Type-Options
);

for my $item (@items) {
    my $app = sub { return [200, ["Content-Type", "text/html"], ["OK"]] };
    test_psgi(
        Aqua::Middleware::SecureHeader->wrap($app, %{$item->{params}}),
        sub {
            my $cb = shift;
            my $res = $cb->(GET "/");
            is $res->code, 200;
            is $res->headers->content_type, "text/html";
            is $res->content, "OK";

            my $params = $item->{params};
            for my $key (@allowed_headers) {
                if (defined $params->{$key}) {
                    is $res->headers->header($key), $params->{$key};
                }
            }
        }
    );
}

done_testing;

