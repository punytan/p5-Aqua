use sane;
use Test::More;
use Aqua::Context;

my $context = Aqua::Context->new( env => {} );

isa_ok $context->session, 'Plack::Session';

done_testing;

