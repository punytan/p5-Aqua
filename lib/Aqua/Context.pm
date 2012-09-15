package Aqua::Context;
use sane;

use Plack::Request;
use Plack::Session;

sub new {
    my ($class, %args) = @_;
    my $request = Plack::Request->new($args{env});
    bless {
        request => $request,
        stash   => {},
    }, $class;
}

sub request    { $_[0]->{request} }
sub session    { Plack::Session->new($_[0]->{request}->env) }
sub csrf_token { $_[0]->session->get("csrf_token") }

sub uri_for {
    my ($self, $path, $args) = @_;

    if ($path =~ m{^/}) {
        $path = substr $path, 1;
    }

    my $uri = $self->request->base;
    $uri->path($uri->path . $path);
    $uri->query_form(%$args) if $args;
    $uri;
}

sub stash { shift->{stash} }

1;
__END__
