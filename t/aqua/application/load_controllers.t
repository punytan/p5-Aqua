use sane;
use Test::More;

use Router::Lazy;
use Aqua::Application;

subtest "success" => sub {
    my $router = Router::Lazy->instance("t::aqua::application::load_controllers");
    $router->get("/login" => "web#index");
    $router->post("/login" => "web#login");

    my $aqua = Aqua::Application->new(router => $router);

    my $app = $aqua->to_app;
    is ref($app), 'CODE';

};

subtest "fail" => sub {
    my $router = Router::Lazy->instance("Nothing");
    $router->get("/" => "Root#index");

    my $aqua = Aqua::Application->new(router => $router);

    local $@;
    eval { $aqua->to_app };

    if (my $e = $@) {
        my $err = quotemeta q|Can't locate <Nothing::Root>|;
        like $e, qr/$err/, 'handler class did not found';
    } else {
        fail "oops, $e";
    }

};

done_testing;

