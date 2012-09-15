use sane;
use Test::More;
use Aqua::Exception;

subtest defualt => sub {
    my $e = Aqua::Exception->new(200);
    is_deeply $e->body, [];
};

subtest specific => sub {
    my $e = Aqua::Exception->new(200, ["OK"]);
    is_deeply $e->body, ["OK"];
};

done_testing;

