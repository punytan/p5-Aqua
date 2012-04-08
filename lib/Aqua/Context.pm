package Aqua::Context;
use sane;

use Plack::Request;
use Plack::Session;

sub new {
    my ($class, %args) = @_;
    my $request = Plack::Request->new($args{env});
    bless { request => $request }, $class;
}

sub req        { $_[0]->{request} }
sub request    { $_[0]->{request} }
sub session    { Plack::Session->new($_[0]->{request}->env) }
sub csrf_token { $_[0]->session->get("csrf_token") }

sub uri_for {
    my ($self, $path, $args) = @_;
    my $uri = $self->request->base;
    $uri->path($uri->path . $path);
    $uri->query_form(%$args) if $args;
    $uri;
}

1;
__END__
