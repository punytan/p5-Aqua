use sane;
use Test::More;
use Aqua::Util;

use FindBin;
use File::Spec;

subtest "can_ok" => sub {
    can_ok 'Aqua::Util', qw(
        findbin
        catfile
        require
    );
};

subtest "findbin" => sub {
    is (Aqua::Util->findbin, $FindBin::Bin);
};

subtest "catfile" => sub {
    is (
        Aqua::Util->catfile("foo", "bar"),
        File::Spec->catfile("foo", "bar")
    );
};

subtest "require" => sub {
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
};

done_testing;
