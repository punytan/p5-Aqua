package Aqua::Handler;
use sane;
use Aqua::Exception;

use Plack::Response;
use Plack::Util;

use URI;
use Carp ();
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
    my ($self, $body, $code, $header, $content_type) = @_;
    $code   ||= 200;
    $header ||= [];
    $content_type ||= "text/html; charset=" . $self->charset;

    Plack::Util::header_set($header, "Content-Type", $content_type);

    $self->throw($code, $body, $header);
}

sub write_json {
    my ($self, $value, $code, $header) = @_;
    state $json = JSON::XS->new->ascii;

    return $self->write(
        $json->encode($value),
        $code,
        $header,
        "application/json; charset=" . $self->charset,
    );
}

sub render {
    my ($self, $template, $args) = @_;
    $args ||= {};

    my $string = $self->template->render($template, {
        %{ $self->{context}{stash} },
        %$args,
        self => $self,
        context => $self->{context},
    });
    my $body = Encode::encode($self->encoding, $string);
    $self->write($body);
}

sub throw {
    my ($self, $code, $body, $header) = @_;
    Aqua::Exception->throw($code, $body, $header);
}

sub redirect {
    my ($self, %args) = @_;
    my $body = $args{body} // '';
    my $code = $args{code} // 302;
    my $header = [];

    my $location;
    if ($args{location}) {
        $location = URI->new($args{location});

    } elsif ($args{uri_for}) {
        my $context = $self->{context};

        my ($path, $query) = (ref $args{uri_for} eq 'HASH')
            ? %{ $args{uri_for} }
            : $args{uri_for};

        $location = $context->uri_for($path, $query);

    } else {
        Carp::croak "redirect method requires `location` or `uri_for` parameter";
    }

    Plack::Util::header_set($header, Location => $location);

    Aqua::Exception->throw($code, $body, $header);
}

1;
__END__

