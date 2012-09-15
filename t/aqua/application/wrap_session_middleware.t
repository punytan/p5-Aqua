use sane;
use Test::More;
use Router::Lazy;
use Aqua::Application;

my $aqua = Aqua::Application->new(router => Router::Lazy->instance("Foo"));
isa_ok $aqua, "Aqua::Application";

subtest "wrap_session_middleware" => sub { # TODO : more pattern
    my $app = $aqua->raw_app;
    is ref( $aqua->wrap_session_middleware($app, { Store => { DBI => {} }, State => {}}) ), 'CODE';
};

done_testing;

