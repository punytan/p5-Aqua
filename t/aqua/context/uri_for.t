use sane;
use Test::More;
use Aqua::Context;

my $context = Aqua::Context->new(
    env => { HTTP_HOST => 'localhost:80' }
);

subtest "just uri_for" => sub {
    my $uri = $context->uri_for("page", { user => "foo" });
    is $uri, "http://localhost/page?user=foo";
};

subtest "with slash" => sub {
    my $uri = $context->uri_for("/page", { user => "foo" });
    is $uri, "http://localhost/page?user=foo";
};

subtest "empty string" => sub {
    my $uri = $context->uri_for("", { user => "foo" });
    is $uri, "http://localhost/?user=foo";
};

done_testing;

