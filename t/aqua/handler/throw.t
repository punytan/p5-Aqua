use sane;
use Test::More;
use t::Util::MakeMockApp;

use Aqua::Handler;
use Aqua::Context;
use Plack::Response;

my $handler = Aqua::Handler->new(
    application => t::Util::MakeMockApp->app(
        template_path => ['share', 'handler', 'template'],
    ),
    context => Aqua::Context->new( env => {} ),
);

subtest "just throw" => sub {
    eval { $handler->throw(500) };
    my $e = $@;
    my $res = Plack::Response->new($e->code, $e->header, $e->body);
    is_deeply $res->finalize, [ 500, [], [] ];
};

subtest "without body" => sub {
    eval { $handler->throw(500, []) };
    my $e = $@;
    my $res = Plack::Response->new($e->code, $e->header, $e->body);
    is_deeply $res->finalize, [ 500, [], [] ];
};

done_testing;

