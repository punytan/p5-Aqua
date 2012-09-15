use sane;
use Test::More;
use Aqua::Exception;

subtest defualt => sub {
    my $e = Aqua::Exception->new;
    is $e->code, 500;
};

subtest specific => sub {
    my $e = Aqua::Exception->new(200);
    is_deeply $e->code, 200;
};

done_testing;

