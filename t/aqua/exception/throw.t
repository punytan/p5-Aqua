use sane;
use Test::More;
use Aqua::Exception;

subtest default => sub {
    eval { Aqua::Exception->throw };
    if (my $e = $@) {
        isa_ok $e, 'Aqua::Exception';
        is $e->code, 500;
        is_deeply $e->header, [];
        is_deeply $e->body,   [];
        is "$e", "500 Internal Server Error";
    }
};

subtest specific => sub {
    eval { Aqua::Exception->throw(404, ['not found'], ['Content-Type' => 'text/plain']) };
    if (my $e = $@) {
        isa_ok $e, 'Aqua::Exception';
        is $e->code, 404;
        is_deeply $e->header, ['Content-Type' => 'text/plain'];
        is_deeply $e->body,   ['not found'];
    }
};

done_testing;


