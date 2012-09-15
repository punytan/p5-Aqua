use sane;
use Test::More;
use Router::Lazy;
use Aqua::Application;

my $aqua = Aqua::Application->new(router => Router::Lazy->instance("Foo"));
isa_ok $aqua, "Aqua::Application";

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

done_testing;

