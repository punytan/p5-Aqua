package t::aqua::application::load_controllers::web;
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
