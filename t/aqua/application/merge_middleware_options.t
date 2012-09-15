use sane;
use Test::More;
use Router::Lazy;
use Aqua::Application;
use Aqua::Util;

my $aqua = Aqua::Application->new(router => Router::Lazy->instance("Foo"));
isa_ok $aqua, "Aqua::Application";

subtest "merge_middleware_options" => sub { # TODO : more pattern
    my $mw = Aqua::Application->merge_middleware_options();
    is_deeply $mw, +{
        Head     => {},
        Runtime  => {},
        Static   => {
            path => qr{^/static/},
            root => Aqua::Util->catfile(Aqua::Util->findbin),
        },
        Session  => {
            Store => { DBI => {} },
            State => { httponly => 1 },
        },
        ContentLength => {},
        ErrorDocument => {},
        SecureHeader  => {
            'X-Frame-Options'  => "DENY",
            'X-XSS-Protection' => "1; mode=block",
            'X-Content-Type-Options' => "nosniff",
        },
        CSRFDefender  => {},
    };

};

done_testing;
