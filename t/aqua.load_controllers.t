use sane;
use Test::More;
use Router::Lazy;
use Aqua;
use t::App::Router;

subtest "success" => sub {
    my $router = t::App::Router->register;

    my $aqua = Aqua->new(router => $router);

    my $app = $aqua->to_app;
    is ref($app), 'CODE';

};

subtest "fail" => sub {
    my $router = Router::Lazy->instance("Nothing");
    $router->get("/" => "Root#index");

    my $aqua = Aqua->new(router => $router);

    local $@;
    eval { $aqua->to_app };

    if ($@) {
        my $err = quotemeta q|Can't locate <Nothing::Root>|;
        like $@, qr/$err/, 'handler class did not found';
    } else {
        fail "woops, $@";
    }

};

done_testing;
