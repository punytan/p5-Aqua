use sane;
use Test::More;
use t::Util::MakeMockApp;

use Encode;
use Aqua::Handler;
use Aqua::Context;

my $handler = Aqua::Handler->new(
    application => t::Util::MakeMockApp->app(
        template_path => [ 'render' ],
    ),
    context => Aqua::Context->new(
        env => {
            'psgix.session' => { csrf_token => 'Lorem ipsum dolor sit amet' }
        }
    ),
);

subtest "just render" => sub {
    eval { $handler->render("page") };
    my $e = $@;
    my $res = Plack::Response->new($e->code, $e->header, $e->body);

    my @body = (
        '<!DOCTYPE html>', '<html>', '<head><title>いろはにほへと</title></head>',
        '<body>Lorem ipsum dolor sit amet,</body>', '</html>', ''
    );

    is_deeply $res->finalize, [
        200,
        [ "Content-Type" => "text/html; charset=UTF-8" ],
        [ Encode::encode_utf8(join "\n", @body) ]
    ];
};

subtest "with args" => sub {
    eval { $handler->render("page", {foo => "bar"}) };
    my $e = $@;
    my $res = Plack::Response->new($e->code, $e->header, $e->body);

    my @body = (
        '<!DOCTYPE html>', '<html>', '<head><title>いろはにほへと</title></head>',
        '<body>Lorem ipsum dolor sit amet,bar</body>', '</html>', ''
    );

    is_deeply $res->finalize, [
        200,
        [ "Content-Type" => "text/html; charset=UTF-8" ],
        [ Encode::encode_utf8(join "\n", @body) ]
    ];
};

subtest "with stash" => sub {
    $handler->{context}->stash->{foo} = "bar";
    eval { $handler->render("page") };
    my $e = $@;
    my $res = Plack::Response->new($e->code, $e->header, $e->body);

    my @body = (
        '<!DOCTYPE html>', '<html>', '<head><title>いろはにほへと</title></head>',
        '<body>Lorem ipsum dolor sit amet,bar</body>', '</html>', ''
    );

    is_deeply $res->finalize, [
        200,
        [ "Content-Type" => "text/html; charset=UTF-8" ],
        [ Encode::encode_utf8(join "\n", @body) ]
    ];
};

done_testing;

