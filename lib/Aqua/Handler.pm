package Aqua::Handler;
use sane;

use Plack::Response;
use Plack::Util;

use Encode   ();
use JSON::XS ();
use HTTP::Status;

sub new {
    my ($class, %args) = @_;
    bless {
        context     => $args{context},
        application => $args{application},
    }, $class;
}

sub charset  { $_[0]->{application}{charset} }
sub encoding { $_[0]->{application}{encoding} }
sub template { $_[0]->{application}{template} }

sub write {
    my ($self, $body, $status, $header, $content_type) = @_;
    $status ||= 200;
    $header ||= [];
    $content_type ||= "text/html; charset=" . $self->charset;

    Plack::Util::header_set($header, "Content-Type", $content_type);

    return Plack::Response->new($status, $header, $body)->finalize;
}

sub write_json {
    my ($self, $value, $status, $header) = @_;
    state $json = JSON::XS->new->ascii;

    return $self->write(
        $json->encode($value),
        $status,
        $header,
        "application/json; charset=" . $self->charset,
    );
}

sub render {
    my ($self, $template, $args) = @_;
    $args ||= {};

    my $string = $self->template->render($template, {
        %$args,
        self => $self,
        context => $self->{context},
    });
    my $body = Encode::encode($self->encoding, $string);
    $self->write($body);
}

sub throw {
    my ($self, $status, $body, $content_type) = @_;

    if (ref $body eq 'ARRAY') {
        $body = HTTP::Status::status_message($status);
    }

    return $self->write($body, $status, [], 'text/plain');
}

1;
__END__

