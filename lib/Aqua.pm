package Aqua;
use sane;
our $VERSION = '0.01';

use Carp ();
use Router::Lazy    ();
use List::MoreUtils ();

use Plack::Util;

use Aqua::Util;
use Text::Xslate;

use constant AQUA_DEBUG => $ENV{AQUA_DEBUG};
use constant PLACK_ENV  => $ENV{PLACK_ENV} || 'development';

our $BIN = Aqua::Util->find_bin;

sub new {
    my ($class, %args) = @_;

    my $charset  = $args{charset} || 'UTF-8';
    my $encoding = $charset =~ /UTF\-8/i ? 'utf8' : $charset;

    my $template = Text::Xslate->new(
        path      => [ Aqua::Util->catfile($BIN, "template") ],
        syntax    => 'Metakolon',
        cache_dir => '/tmp',
        module    => [
            'Text::MultiMarkdown' => ['markdown'],
            'JavaScript::Value::Escape' => ['js']
        ],
        verbose => (PLACK_ENV eq 'development' ? 2 : 1),
        %{ $args{template} || {} },
    );

    my $middlewares = __PACKAGE__->merge_middleware_options(
        middlewares => $args{middlewares}
    );

    return bless {
        charset  => $charset,
        encoding => $encoding,
        template => $template,
        middlewares => $middlewares,
    }, $class;
}

sub merge_middleware_options {
    my ($class, %args) = @_;

    my $mw = delete $args{middlewares} || +{};

    my $head    = $mw->{Head}    // 1;
    my $runtime = $mw->{Runtime} // 1;

    my $content_length = $mw->{ContentLength} // 1;
    my $errordocument  = $mw->{ErrorDocument} // 1;

    my $static = delete $mw->{Static} // +{
        path => qr{^/static/},
        root => Aqua::Util->catfile($BIN, "public"),
    };

    my $secure_header = delete $mw->{SecureHeader} // +{
        'X-Frame-Options'  => "DENY",
        'X-XSS-Protection' => "1; mode=block",
        'X-Content-Type-Options' => "nosniff",
    };

    my $csrf_defender = delete $mw->{CSRFDefender} // +{};

    my $session = delete $mw->{Session} // +{};
    my $session_store = delete $session->{Store} // { DBI => { } };
    my $session_state = delete $session->{State} // { httponly => 1 };

    return +{
        Head     => $head,
        Runtime  => $runtime,
        Static   => $static,
        Session  => {
            Store => $session_store,
            State => $session_state,
        },
        ContentLength => $content_length,
        ErrorDocument => $errordocument,
        SecureHeader  => $secure_header,
        CSRFDefender  => $csrf_defender,
    };

}

sub to_app {
    my $self = shift;

    $self->load_controllers;

    my $app = sub {
        my $env = shift;

        my $method = uc $env->{REQUEST_METHOD} eq 'HEAD'
            ? 'HEAD' : undef;

        if (my $ret = Router::Lazy->match($env, $method)) {
            my ($controller, $action)
                = ($ret->{controller}, $ret->{action});

            return $controller->new(
                env => $env,
                application => $self,
            )->$action(@{$ret->{args}});

        }

        for my $method ( grep { $_ ne uc $env->{REQUEST_METHOD} } qw(GET POST PUT DELETE) ) {
            if (my $ret = Router::Lazy->match($env, $method)) {
                return [405, [], []]; # 405 Method Not Allowed
            }
        }

        return [404, [], []];
    };

    $app = $self->wrap_middlewares($app);

    return $app;
}

sub wrap_middlewares {
    my ($self, $app) = @_;
    my $mw = $self->{middlewares};

    if ($mw->{Static}) {
        require Plack::Middleware::Static;
        $app = Plack::Middleware::Static->wrap($app,
            %{ $mw->{Static} }
        );
    }

    if ($mw->{SecureHeader}) {
        require Aqua::Middleware::SecureHeader;
        $app = Aqua::Middleware::SecureHeader->wrap($app,
            %{ $mw->{SecureHeader} }
        );
    }

    if ($mw->{Head}) {
        require Plack::Middleware::Head;
        $app = Plack::Middleware::Head->wrap($app);
    }

    if ($mw->{Session} && $mw->{CSRFDefender}) {
        require Aqua::Middleware::CSRFDefender;
        $app = Aqua::Middleware::CSRFDefender->wrap($app,
            %{ $mw->{CSRFDefender} }
        );
    }

    if ($mw->{Session}) {
        $app = $self->wrap_session_middleware($app);
    }

    if ($mw->{ErrorDocument}) {
        require Aqua::Middleware::ErrorDocument;
        $app = Aqua::Middleware::ErrorDocument->wrap($app);
    }

    if ($mw->{ContentLength}) {
        require Plack::Middleware::ContentLength;
        $app = Plack::Middleware::ContentLength->wrap($app);
    }

    if ($mw->{Runtime}) {
        require Plack::Middleware::Runtime;
        $app = Plack::Middleware::Runtime->wrap($app);
    }

    return $app;
}

sub wrap_session_middleware {
    my ($self, $app) = @_;

    my $session    = $self->{middlewares}{Session};
    my ($storarge) = keys %{ $session->{Store} };
    my $handler    = "Plack::Session::Store::$storarge";

    my $state_options = $session->{State} || +{};
    my $store_options = $storarge ne 'Null'
        ? $session->{Store}{$storarge} : +{} ;

    if (exists $store_options->{dbh}) {
        $store_options->{get_dbh}
            = sub { $store_options->{dbh} };

    } elsif (not exists $store_options->{get_dbh}) {
        require DBI;

        my $dbh = DBI->connect("dbi:SQLite::memory:","","", {RaiseError => 1});
        $dbh->do('CREATE TABLE sessions (id CHAR(72) PRIMARY KEY, session_data TEXT)');

        $store_options->{get_dbh} = sub { $dbh };
    }

    Plack::Util::load_class $handler;
    require Plack::Session::State::Cookie;
    require Plack::Middleware::Session;

    return Plack::Middleware::Session->wrap($app,
        store => $handler->new(%$store_options),
        state => Plack::Session::State::Cookie->new(%$state_options),
    );
}

sub load_controllers {
    my $self = shift;

    for my $method (keys %$Router::Lazy::Rules) {
        for my $rule (@{ $Router::Lazy::Rules->{$method} }) {
            my ($controller, $action) = ($rule->{controller}, $rule->{action});

            local $@;
            eval { Plack::Util::load_class $controller };

            unless ($controller->can($action)) {
                Carp::croak "<$controller#$action> is not callable."
            }
        }

    }

}

1;
__END__

=head1 NAME

Aqua -

=head1 SYNOPSIS

  use Aqua;

=head1 DESCRIPTION

Aqua is

=head1 AUTHOR

punytan E<lt>punytan@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut