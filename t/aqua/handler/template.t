use sane;
use Test::More;
use Aqua::Handler;
use Aqua::Context;
use t::Util::MakeMockApp;

my $handler = Aqua::Handler->new(
    application => t::Util::MakeMockApp->app(
        template_path => ['share', 'handler', 'template'],
    ),
    context => Aqua::Context->new( env => {} ),
);

isa_ok $handler, 'Aqua::Handler';
isa_ok $handler->template, 'Text::Xslate';

done_testing;

