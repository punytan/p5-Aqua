package t::aqua::applicaation::_wrap::web;
use sane;
use parent 'Aqua::Handler';

sub index {
    my ($self, $context) = @_;
    $self->write("root");
}

package t::aqua::applicaation::_wrap::router;
use sane;
use Router::Lazy;

sub register {
    my $instance = Router::Lazy->instance('t::aqua::applicaation::_wrap');
    $instance->get("/" => "web#index");
    return $instance;
}

package main;
use sane;
use Test::More;
use Router::Lazy;
use Aqua::Application;
use LWP::UserAgent;
use LWP::Protocol::PSGI;
use t::App::Router;

my $router = t::App::Router->register;
my $aqua = Aqua::Application->new(router => $router);
$aqua->load_controllers;

subtest raw_app => sub {
    my $app   = $aqua->raw_app;
    my $gurad = LWP::Protocol::PSGI->register($app);
    my $res   = LWP::UserAgent->new->get('http://localhost/');
    is $res->code, 200;
    is $res->headers->header('X-Runtime'), undef;
    is $res->content, 'root';
};

subtest wrap => sub {
    my $runtime_app = $aqua->_wrap("Runtime", $aqua->raw_app, {});
    my $gurad = LWP::Protocol::PSGI->register($runtime_app);
    my $res   = LWP::UserAgent->new->get('http://localhost/');
    is $res->code, 200;
    like $res->headers->header('X-Runtime'), qr/^\d\.\d+$/;
    is $res->content, 'root';
};

done_testing;

