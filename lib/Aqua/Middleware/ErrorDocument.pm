package Aqua::Middleware::ErrorDocument;
use sane;
use parent 'Plack::Middleware';

use Aqua::Util;
use Plack::Util;
use HTTP::Status 'is_success';

our $BIN = Aqua::Util->findbin;

sub call {
    my $self = shift;
    my $response = $self->app->(@_);
    $self->response_cb($response, sub {
        my $res = shift;

        if (is_success($res->[0]) or scalar @{$res->[2]}) {
            return;
        }

        my $header = Plack::Util::headers($res->[1]);
        my $path = Aqua::Util->catfile($BIN, "errordoc", $res->[0]);

        if (-r $path) {
            open my $fh, "<", $path or die "$path: $!";
            $res->[2] = $fh;

            $header->remove("Content-Length");
            $header->set("Content-Type" => "text/html; charset=UTF-8");

        } else {
            $res->[2] = [ HTTP::Status::status_message($res->[0]) ];
            $header->remove("Content-Length");
            $header->set("Content-Type" => "text/plain");

        }

    });
}

1;
__END__

