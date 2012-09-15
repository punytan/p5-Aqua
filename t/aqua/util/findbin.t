use sane;
use Test::More;
use FindBin;
use File::Spec;

use Aqua::Util;

subtest "findbin" => sub {
    is (Aqua::Util->findbin, $FindBin::Bin);
};

done_testing;

