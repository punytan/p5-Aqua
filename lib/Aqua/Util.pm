package Aqua::Util;
use sane;
use FindBin;
use File::Spec;

sub find_bin { $FindBin::Bin }
sub catfile  { shift; File::Spec->catfile(@_) }

1;
__END__