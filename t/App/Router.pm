package t::App::Router;
use sane;
use Router::Lazy;

namespace "t::App::Web";

get  "/" => "Root#index";
get  "/token" => "Root#token";
get  "/login" => "Login#index";
post "/login" => "Login#login";


1;
__END__
