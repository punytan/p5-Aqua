package Aqua::Util;
use sane;
use FindBin;
use File::Spec;

sub findbin { $FindBin::Bin }
sub catfile { shift; File::Spec->catfile(@_) }

sub require {
    my (undef, $class, $method) = @_;
    unless ($class->can($method || "new")) {
        my $path = $class;
        $path =~ s|::|/|g;
        require "$path.pm"; ## no critic
    }
}

1;
__END__
