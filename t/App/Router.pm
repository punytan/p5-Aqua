package t::App::Router;
use sane;
use Router::Lazy;

sub register {
    my $r = Router::Lazy->instance("t::App::Web");
    $r->get("/" => "Root#index");
    $r->get("/token" => "Root#token");
    $r->get("/login" => "Login#index");
    $r->post("/login" => "Login#login");

    return $r;
}

1;
__END__
