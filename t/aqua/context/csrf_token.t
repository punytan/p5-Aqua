use sane;
use Test::More;
use Aqua::Context;

my $context = Aqua::Context->new(
    env => {
        'psgix.session' => { csrf_token => 'Lorem ipsum dolor sit amet' }
    }
);

is $context->csrf_token, 'Lorem ipsum dolor sit amet';

done_testing;

