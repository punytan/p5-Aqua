use sane;
use Test::More;
use Aqua::Util;

use FindBin;
use File::Spec;

can_ok 'Aqua::Util', qw(find_bin catfile);

is (Aqua::Util->find_bin, $FindBin::Bin);
is (Aqua::Util->catfile("foo", "bar"), File::Spec->catfile("foo", "bar"));

done_testing;
