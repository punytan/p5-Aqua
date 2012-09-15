use sane;
use Test::More;
use Aqua::Context;

my $context = Aqua::Context->new( env => {} );

$context->stash->{foo} = "bar";
is $context->stash->{foo}, "bar";

done_testing;

