package t::Util::Router;
use sane;
use Router::Lazy;

namespace "Foo::Web";

get  "/"          => "Root#index";
get  "/get/:year" => "Root#get";

1;
