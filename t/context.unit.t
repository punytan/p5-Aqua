use sane;
use Test::More;
use Aqua::Context;

subtest "new_ok" => sub {
    new_ok "Aqua::Context", [ env => {} ];
};

subtest "can_ok" => sub {
    can_ok "Aqua::Context", qw(
        new
        req
        request
        session
        csrf_token
        uri_for
        stash
    );
};

my $context = Aqua::Context->new(env => {
    'psgix.session' => { csrf_token => 'Lorem ipsum dolor sit amet' },
    'SCRIPT_NAME' => '',
    'SERVER_NAME' => 0,
    'HTTP_ACCEPT_ENCODING' => 'gzip, deflate',
    'HTTP_CONNECTION' => 'keep-alive',
    'PATH_INFO' => '/',
    'HTTP_ACCEPT' => 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'REQUEST_METHOD' => 'GET',
    'psgi.multithread' => '',
    'HTTP_USER_AGENT' => 'Mozilla/5.0',
    'QUERY_STRING' => '',
    'SERVER_PORT' => 5000,
    'psgix.input.buffered' => 1,
    'HTTP_ACCEPT_LANGUAGE' => 'en-us,ja;q=0.7,en;q=0.3',
    'REMOTE_ADDR' => '127.0.0.1',
    'SERVER_PROTOCOL' => 'HTTP/1.1',
    'psgi.streaming' => 1,
    'psgi.errors' => *::STDERR,
    'REQUEST_URI' => '/',
    'psgi.version' => [ 1, 1 ],
    'psgi.nonblocking' => '',
    'psgi.url_scheme' => 'http',
    'psgi.run_once' => '',
    'HTTP_HOST' => 'localhost:80',
});

subtest "accessor methods" => sub {
    isa_ok $context->req,      'Plack::Request';
    isa_ok $context->request,  'Plack::Request';
    isa_ok $context->session,  'Plack::Session';
    is $context->csrf_token,   'Lorem ipsum dolor sit amet';
};

subtest "uri_for" => sub {
    subtest "just uri_for" => sub {
        my $uri = $context->uri_for("page", { user => "foo" });
        is $uri, "http://localhost/page?user=foo";
    };
};

subtest "stash" => sub {
    $context->stash->{foo} = "bar";
    is $context->stash->{foo}, "bar";
};

done_testing;


