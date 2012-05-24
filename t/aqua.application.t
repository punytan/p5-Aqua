use sane;
use Test::More;
use Router::Lazy;
use Aqua::Application;
use Aqua::Util;

subtest "can_ok" => sub {
    can_ok 'Aqua::Application', qw(
        new
        raw_app
        to_app
        merge_middleware_options
        _wrap
        wrap_default_middlewares
        wrap_session_middleware
        load_controllers
    );
};

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

subtest "raw_app" => sub { # TODO : more pattern
    my $app = $aqua->raw_app;
    is ref($app), 'CODE';
};

subtest "to_app" => sub { # TODO : more pattern
    my $app = $aqua->to_app;
    is ref($app), 'CODE';
};

subtest "wrap_default_middlewares" => sub { # TODO : more pattern
    my $app = $aqua->raw_app;
    is ref( $aqua->wrap_default_middlewares($app) ), 'CODE';
};

subtest "wrap_session_middleware" => sub { # TODO : more pattern
    my $app = $aqua->raw_app;
    is ref( $aqua->wrap_session_middleware($app, { Store => { DBI => {} }, State => {}}) ), 'CODE';
};

done_testing;


