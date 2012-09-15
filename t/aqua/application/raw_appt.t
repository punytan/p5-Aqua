use sane;
use Test::More;
use Router::Lazy;
use Aqua::Application;

my $aqua = Aqua::Application->new(router => Router::Lazy->instance("Foo"));

subtest "raw_app" => sub { # TODO : more pattern
    my $app = $aqua->raw_app;
    is ref($app), 'CODE';
};

done_testing;

