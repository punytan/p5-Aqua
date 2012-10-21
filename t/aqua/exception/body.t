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

subtest filehandle => sub {
    open my $fh, '<', __FILE__;
    my $e = Aqua::Exception->new(200, $fh);
    is_deeply $e->body, $fh;
};

done_testing;

