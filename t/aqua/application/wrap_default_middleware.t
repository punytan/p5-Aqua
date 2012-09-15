use sane;
use Test::More;
use Router::Lazy;
use Aqua::Application;

my $aqua = Aqua::Application->new(router => Router::Lazy->instance("Foo"));
isa_ok $aqua, "Aqua::Application";

subtest "wrap_default_middlewares" => sub { # TODO : more pattern
    my $app = $aqua->raw_app;
    is ref( $aqua->wrap_default_middlewares($app) ), 'CODE';
};

done_testing;

