package t::App::Web::Root;
use sane;
use parent 'Aqua::Handler';

sub index {
    my ($self, $context) = @_;
    $self->write("root");
}

sub token {
    my ($self, $context) = @_;
    $self->write( $context->csrf_token );
}

1;
