use sane;
use Test::More;
use t::Util::MakeMockApp;

use Aqua::Handler;
use Aqua::Context;

my $handler = Aqua::Handler->new(
    application => t::Util::MakeMockApp->app(
        template_path => ['share', 'handler', 'template'],
    ),
    context => Aqua::Context->new( env => {} ),
);

subtest "just write" => sub {
    eval { $handler->write_json( { key => "value" } ) };
    my $e = $@;
    my $res = Plack::Response->new($e->code, $e->header, $e->body);
    is_deeply $res->finalize, [ 200, [ "Content-Type" => "application/json; charset=UTF-8" ], [ '{"key":"value"}' ] ];
};

subtest "with status" => sub {
    eval { $handler->write_json({key => "value"}, 500) };
    my $e = $@;
    my $res = Plack::Response->new($e->code, $e->header, $e->body);
    is_deeply $res->finalize, [ 500, [ "Content-Type" => "application/json; charset=UTF-8" ], [ '{"key":"value"}' ] ];
};

done_testing;

