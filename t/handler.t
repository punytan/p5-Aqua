use sane;
use Test::More;
use Aqua::Handler;
use Aqua::Context;
use t::Util::MakeMockApp;
use Encode;

subtest "new_ok" => sub {
    new_ok "Aqua::Handler", [ env => {} ];
};

subtest "can_ok" => sub {
    can_ok "Aqua::Handler", qw(
        new
        charset
        encoding
        template
        write
        write_json
        render
        throw
        redirect
    );
};

my $env = {
    'psgix.session' => {
        csrf_token => 'Lorem ipsum dolor sit amet'
    },
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
};

my $handler = Aqua::Handler->new(
    application => t::Util::MakeMockApp->app(
        template_path => ['share', 'handler', 'template'],
    ),
    context => Aqua::Context->new( env => $env ),
);

isa_ok $handler, 'Aqua::Handler';

subtest "accessor methods" => sub {
    isa_ok $handler->template, 'Text::Xslate';

    is $handler->charset,   'UTF-8';
    is $handler->encoding,  'utf8';
};

subtest "write" => sub {
    subtest "just write" => sub {
        my $res = $handler->write("Hi");
        is_deeply $res, [
            200,
            [ "Content-Type" => "text/html; charset=UTF-8" ],
            [ "Hi" ]
        ];
    };

    subtest "with status" => sub {
        my $res = $handler->write("Hi", 500);
        is_deeply $res, [
            500,
            [ "Content-Type" => "text/html; charset=UTF-8" ],
            [ "Hi" ]
        ];
    };

    subtest "with content-type" => sub {
        my $res = $handler->write("Hi", 200, [], "text/plain");
        is_deeply $res, [
            200,
            [ "Content-Type" => "text/plain" ],
            [ "Hi" ]
        ];
    };

};

subtest "write_json" => sub {
    subtest "just write" => sub {
        my $res = $handler->write_json({key => "value"});
        is_deeply $res, [
            200,
            [ "Content-Type" => "application/json; charset=UTF-8" ],
            [ '{"key":"value"}' ]
        ];
    };

    subtest "with status" => sub {
        my $res = $handler->write_json({key => "value"}, 500);
        is_deeply $res, [
            500,
            [ "Content-Type" => "application/json; charset=UTF-8" ],
            [ '{"key":"value"}' ]
        ];
    };

};

subtest "render" => sub {
    subtest "just render" => sub {
        my $res = $handler->render("page");
        my @body = (
            '<!DOCTYPE html>', '<html>', '<head><title>いろはにほへと</title></head>',
            '<body>Lorem ipsum dolor sit amet,</body>', '</html>', ''
        );

        is_deeply $res, [
            200,
            [ "Content-Type" => "text/html; charset=UTF-8" ],
            [ Encode::encode_utf8(join "\n", @body) ]
        ];
    };

    subtest "with args" => sub {
        my $res = $handler->render("page", {foo => "bar"});
        my @body = (
            '<!DOCTYPE html>', '<html>', '<head><title>いろはにほへと</title></head>',
            '<body>Lorem ipsum dolor sit amet,bar</body>', '</html>', ''
        );

        is_deeply $res, [
            200,
            [ "Content-Type" => "text/html; charset=UTF-8" ],
            [ Encode::encode_utf8(join "\n", @body) ]
        ];
    };

    subtest "with stash" => sub {
        $handler->{context}->stash->{foo} = "bar";
        my $res = $handler->render("page");
        my @body = (
            '<!DOCTYPE html>', '<html>', '<head><title>いろはにほへと</title></head>',
            '<body>Lorem ipsum dolor sit amet,bar</body>', '</html>', ''
        );

        is_deeply $res, [
            200,
            [ "Content-Type" => "text/html; charset=UTF-8" ],
            [ Encode::encode_utf8(join "\n", @body) ]
        ];
    };

};

subtest "throw" => sub {
    subtest "just throw" => sub {
        my $res = $handler->throw(500);
        is_deeply $res, [
            500,
            [ "Content-Type" => "text/plain" ],
            [ ]
        ];
    };

    subtest "without body" => sub {
        my $res = $handler->throw(500, []);
        is_deeply $res, [
            500,
            [ "Content-Type" => "text/plain" ],
            [ 'Internal Server Error' ]
        ];
    };

};

subtest redirect => sub {
    subtest location => sub {
        my $res = $handler->redirect(location => 'http://google.com');
        is_deeply $res, [
            302,
            [
                "Location" => "http://google.com",
                "Content-Type" => "text/html; charset=UTF-8" ],
            []
        ];
    };

    subtest uri_for => sub {
        my $res = $handler->redirect(
            uri_for => {
                'foo' => { query => 'string' }
            }
        );
        is_deeply $res, [
            302,
            [
                "Location" => "http://localhost/foo?query=string",
                "Content-Type" => "text/html; charset=UTF-8",
            ],
            []
        ];
    };

    subtest exception => sub {
        local $@;
        eval { $handler->redirect };
        like $@, qr/redirect method requires/;
    };
};

done_testing;

