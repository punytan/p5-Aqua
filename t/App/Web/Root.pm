package t::App::Web::Root;
use sane;
use parent 'Aqua::Handler';

sub index {
    shift->write("root");
}

sub token {
    $_[0]->write( $_[0]->csrf_token );
}

1;
