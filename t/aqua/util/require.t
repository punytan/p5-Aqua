use sane;
use Test::More;
use FindBin;
use File::Spec;

use Aqua::Util;

subtest "success" => sub {
    ok( Aqua::Util->require("Aqua") );
};

subtest "success with callable method" => sub {
    ok( Aqua::Util->require("Aqua", "raw_app") );
};

subtest "fail" => sub {
    local $@;
    eval { Aqua::Util->require("Aqua::Foo") };
    ok $@;
};

done_testing;

