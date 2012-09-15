use sane;
use Test::More;
use Aqua::Handler;
use Aqua::Context;
use t::Util::MakeMockApp;
use Encode;

my $handler = Aqua::Handler->new(
    application => t::Util::MakeMockApp->app(
        template_path => ['share', 'handler', 'template'],
    ),
    context => Aqua::Context->new( env => {} ),
);

subtest "just write" => sub {
    eval { $handler->write("Hi") };
    my $e = $@;
    my $res = Plack::Response->new($e->code, $e->header, $e->body);
    is_deeply $res->finalize, [ 200, [ "Content-Type" => "text/html; charset=UTF-8" ], [ "Hi" ] ];
};

subtest "with status" => sub {
    eval { $handler->write("Hi", 500) };
    my $e = $@;
    my $res = Plack::Response->new($e->code, $e->header, $e->body);
    is_deeply $res->finalize, [ 500, [ "Content-Type" => "text/html; charset=UTF-8" ], [ "Hi" ] ];
};

subtest "with content-type" => sub {
    eval { $handler->write("Hi", 200, [], "text/plain") };
    my $e = $@;
    my $res = Plack::Response->new($e->code, $e->header, $e->body);
    is_deeply $res->finalize, [ 200, [ "Content-Type" => "text/plain" ], [ "Hi" ] ];
};

done_testing;

