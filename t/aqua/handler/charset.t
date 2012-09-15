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

isa_ok $handler, 'Aqua::Handler';

is $handler->charset, 'UTF-8';

done_testing;


