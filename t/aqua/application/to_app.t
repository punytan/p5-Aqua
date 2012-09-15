use sane;
use Test::More;
use Router::Lazy;
use Aqua::Application;

my $aqua = Aqua::Application->new(router => Router::Lazy->instance("Foo"));

subtest "to_app" => sub { # TODO : add more pattern
    my $app = $aqua->to_app;
    is ref($app), 'CODE';
};

done_testing;

