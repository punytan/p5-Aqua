use sane;
use Test::More;
use Router::Lazy;
use Aqua;
use Aqua::Util;

subtest "can_ok" => sub {
    can_ok 'Aqua', qw(
        new
        merge_middleware_options
        raw_app
        to_app
        wrap_middlewares
        load_controllers
    );
};

my $aqua = Aqua->new(
    handler_class => 'Foo'
);

isa_ok $aqua, "Aqua";

subtest "merge_middleware_options" => sub { # TODO : more pattern
    my $mw = Aqua->merge_middleware_options();
    is_deeply $mw, +{
        Head     => 1,
        Runtime  => 1,
        Static   => {
            path => qr{^/static/},
            root => Aqua::Util->catfile(Aqua::Util->findbin),
        },
        Session  => {
            Store => { DBI => {} },
            State => { httponly => 1 },
        },
        ContentLength => 1,
        ErrorDocument => 1,
        SecureHeader  => {
            'X-Frame-Options'  => "DENY",
            'X-XSS-Protection' => "1; mode=block",
            'X-Content-Type-Options' => "nosniff",
        },
        CSRFDefender  => {},
    };

};

subtest "raw_app" => sub { # TODO : more pattern
    my $app = $aqua->raw_app;
    is ref($app), 'CODE';
};

subtest "to_app" => sub { # TODO : more pattern
    my $app = $aqua->to_app;
    is ref($app), 'CODE';
};

subtest "wrap_middlewares" => sub { # TODO : more pattern
    my $app = $aqua->raw_app;
    is ref( $aqua->wrap_middlewares($app) ), 'CODE';
};

subtest "wrap_session_middleware" => sub { # TODO : more pattern
    my $app = $aqua->raw_app;
    is ref( $aqua->wrap_session_middleware($app) ), 'CODE';
};

done_testing;

