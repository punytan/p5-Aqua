package Aqua::Middleware::SecureHeader;
use sane;
use parent 'Plack::Middleware';

use Plack::Util;

my @allowed_headers = qw(
    X-XSS-Protection
    X-Frame-Options
    X-Content-Type-Options
);

sub call {
    my $self = shift;

    my $res = $self->app->(@_);
    $self->response_cb($res, sub {
        my $res = shift;

        for (@allowed_headers) {
            if (defined $self->{$_}) {
                Plack::Util::header_set($res->[1], $_ => $self->{$_});
            }
        }

    });
}

1;
__END__

