use sane;
use Test::More;
use FindBin;
use File::Spec;

use Aqua::Util;

subtest "catfile" => sub {
    is (
        Aqua::Util->catfile("foo", "bar"),
        File::Spec->catfile("foo", "bar")
    );
};

done_testing;

