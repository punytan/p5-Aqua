package t::App::Web::Login;
use sane;
use parent 'Aqua::Handler';

sub index {
    my $self = shift;
    $self->render("login/index");
}

sub login {
    shift->write("OK");
}

1;

