use sane;
use Test::More;
use Aqua::Exception;

subtest defualt => sub {
    my $e = Aqua::Exception->new(200, undef);
    is_deeply $e->header, [];
};

subtest specific => sub {
    my $e = Aqua::Exception->new(200, undef, ['Content-Type' => 'text/html']);
    is_deeply $e->header, ['Content-Type' => 'text/html'];
};

done_testing;


