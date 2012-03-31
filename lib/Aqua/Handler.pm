package Aqua::Handler;
use sane;

use Plack::Request;
use Plack::Response;
use Plack::Session;
use Plack::Util;

use Encode   ();
use JSON::XS ();
use HTTP::Status;

sub new {
    my ($class, %args) = @_;
    bless {
        request     => Plack::Request->new($args{env}),
        application => $args{application},
    }, $class;
}

sub req      { $_[0]->{request} }
sub request  { $_[0]->{request} }
sub session  { Plack::Session->new($_[0]->{request}->env) }
sub charset  { $_[0]->{application}{charset} }
sub encoding { $_[0]->{application}{encoding} }
sub template { $_[0]->{application}{template} }

sub csrf_token { $_[0]->session->get("csrf_token") }

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

    my $string = $self->template->render($template, { %$args, self => $self });
    my $body = Encode::encode($self->encoding, $string);
    $self->write($body);
}

sub throw {
    my ($self, $status, $body, $content_type) = @_;
    $body ||= HTTP::Status::status_message($status);
    return $self->write($body, $status, [], 'text/plain');
}

sub uri_for {
    my ($self, $path, %args) = @_;
    my $uri = $self->request->base;
    $uri->path($uri->path . $path);
    $uri->query_form(%args) if %args;
    $uri;
}

1;
__END__

