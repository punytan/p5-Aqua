use sane;
use Test::More;
use Aqua::Context;

subtest "new_ok" => sub {
    new_ok "Aqua::Context", [ env => {} ];
};

my $context = Aqua::Context->new( env => { } );

isa_ok $context, 'Aqua::Context';

done_testing;

