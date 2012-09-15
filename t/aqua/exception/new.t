use sane;
use Test::More;
use Aqua::Exception;

my $e = Aqua::Exception->new(200);

isa_ok $e, 'Aqua::Exception';

done_testing;


