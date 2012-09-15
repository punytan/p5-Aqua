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
    context => Aqua::Context->new( env => { HTTP_HOST => 'localhost:80' } ),
);

subtest location => sub {
    eval { $handler->redirect(location => 'http://google.com') };
    my $e = $@;
    my $res = Plack::Response->new($e->code, $e->header, $e->body);
    is_deeply $res->finalize, [ 302, [ Location => "http://google.com"], [] ];
};

subtest uri_for => sub {
    eval { $handler->redirect( uri_for => { foo => { query => 'string' } } ) };
    my $e = $@;
    my $res = Plack::Response->new($e->code, $e->header, $e->body);
    is_deeply $res->finalize, [ 302, [ Location => "http://localhost/foo?query=string" ], [] ];
};

subtest exception => sub {
    eval { $handler->redirect };
    like $@, qr/redirect method requires/;
};

done_testing;

