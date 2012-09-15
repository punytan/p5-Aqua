use sane;
use Test::More;
use Aqua::Exception;

my $e = Aqua::Exception->new(200);
is "$e", "200 OK";

done_testing;


