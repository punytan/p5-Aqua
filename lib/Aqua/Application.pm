package Aqua::Application;
use sane;
our $VERSION = '0.01';

use Carp ();
use Router::Lazy;
use Aqua::Util;
use Text::Xslate;

use constant AQUA_DEBUG => $ENV{AQUA_DEBUG};
use constant PLACK_ENV  => $ENV{PLACK_ENV} || 'development';

our $BIN = Aqua::Util->findbin;

sub new {
    my ($class, %args) = @_;

    my $router = $args{router}
        or Carp::croak "router is required argument";

    my $charset  = $args{charset} || 'UTF-8';
    my $encoding = $charset =~ /UTF\-8/i ? 'utf8' : $charset;

    my $context_class = (sub {
        my %args = @_;
        $args{context_class} ||= 'Aqua::Context';
        Aqua::Util->require($args{context_class});
        return $args{context_class};
    }->(%args));

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

    return bless {
        router   => $router,
        charset  => $charset,
        encoding => $encoding,
        template => $template,
        context  => $context_class,
    }, $class;
}

sub raw_app {
    my $self = shift;

    return sub {
        my $env = shift;
        my $method = uc $env->{REQUEST_METHOD} eq 'HEAD' ? 'HEAD' : undef;
        my $ret = $self->{router}->match($env, $method);

        unless ($ret) {
            for my $method ( grep { $_ ne uc $env->{REQUEST_METHOD} } qw(GET POST PUT DELETE) ) {
                if (my $ret = $self->{router}->match($env, $method)) {
                    return [405, [], []]; # 405 Method Not Allowed
                }
            }
            return [404, [], []];
        }

        my ($controller, $action, @args) = ($ret->{controller}, $ret->{action}, @{ $ret->{args} || [] });
        my $context = $self->{context}->new(env => $env);

        AQUA_DEBUG && printf STDERR "Match: <%s#%s>, args: <%s>\n",
            $controller, $action, join ", ", (grep { defined } @args);

        my $c = $controller->new(
            context     => $context,
            application => $self,
        );

        if (my $response = eval { $c->$action($context, @args) }) {
            return $response;
        } else {
            my $e = $@;
            if (ref $e && $e->isa('Aqua::Exception')) {
                my $res = $context->request->new_response($e->code, $e->header, $e->body);
                return $res->finalize;
            } else {
                Carp::croak $e;
            }
        }

    };
}

sub to_app {
    my $self = shift;
    $self->load_controllers;
    $self->wrap_default_middlewares($self->raw_app, {});
}

sub merge_middleware_options {
    my ($class, %mw) = @_;

    my $defaults = {
        Head     => {},
        Runtime  => {},
        ContentLength => {},
        ErrorDocument => {},
        CSRFDefender  => {},
        Static => {
            path => qr{^/static/},
            root => Aqua::Util->catfile($BIN),
        },
        SecureHeader => {
            'X-Frame-Options'  => "DENY",
            'X-XSS-Protection' => "1; mode=block",
            'X-Content-Type-Options' => "nosniff",
        },
        Session => {
            Store => { DBI => { } },
            State => { httponly => 1 },
        },
    };

    return +{ %$defaults, %mw };
}

sub _wrap {
    my ($self, $class, $orig_app, $args) = @_;
    my $pkg = $class =~ /^\+(.+)/ ? $1 : "Plack::Middleware::$class";

    my $app = eval {
        Aqua::Util->require($pkg, "wrap");
        AQUA_DEBUG && print STDERR "Enable Middleware <$pkg>\n";
        $pkg->wrap($orig_app, %{ $args || +{} });
    };
    if (my $e = $@) {
        Carp::croak $e;
    };

    return $app;
}

sub wrap_default_middlewares {
    my ($class, $app, $options) = @_;

    my $mw = __PACKAGE__->merge_middleware_options(%$options);

    if ($mw->{Static}) {
        $app = __PACKAGE__->_wrap("Static", $app, $mw->{Static});
    }

    if ($mw->{SecureHeader}) {
        $app = __PACKAGE__->_wrap("+Aqua::Middleware::SecureHeader", $app, $mw->{SecureHeader});
    }

    if ($mw->{Head}) {
        $app = __PACKAGE__->_wrap("Head", $app, $mw->{Head});
    }

    if ($mw->{Session} && $mw->{CSRFDefender}) {
        $app = __PACKAGE__->_wrap("+Aqua::Middleware::CSRFDefender", $app, $mw->{CSRFDefender});
    }

    if ($mw->{Session}) {
        $app = __PACKAGE__->wrap_session_middleware($app, $mw->{Session});
    }

    if ($mw->{ErrorDocument}) {
        $app = __PACKAGE__->_wrap("+Aqua::Middleware::ErrorDocument", $app, $mw->{ErrorDocument});
    }

    if ($mw->{ContentLength}) {
        $app = __PACKAGE__->_wrap("ContentLength", $app, $mw->{ContentLength});
    }

    if ($mw->{Runtime}) {
        $app = __PACKAGE__->_wrap("Runtime", $app, $mw->{Runtime});
    }

    return $app;
}

sub wrap_session_middleware {
    my ($class, $app, $options) = @_;

    my $store = do {
        my ($storage) = %{ $options->{Store} };
        my $handler = "Plack::Session::Store::$storage";
        my $store_options = $options->{Store}{$storage} || {};

        if (exists $store_options->{dbh}) {
            $store_options->{get_dbh} = sub { $store_options->{dbh} };

        } elsif (not exists $store_options->{get_dbh}) {
            require DBI;
            my $dbh = DBI->connect("dbi:SQLite::memory:", "", "", { RaiseError => 1 });
            $dbh->do( 'CREATE TABLE sessions(id CHAR(72) PRIMARY KEY, session_data TEXT)');
            $store_options->{get_dbh} = sub { $dbh };
        }

        Aqua::Util->require($handler);
        $handler->new(%$store_options);
    };

    my $state = do {
        require Plack::Session::State::Cookie;
        Plack::Session::State::Cookie->new(%{ $options->{State} })
    };

    AQUA_DEBUG && print STDERR "Enable Middleware <Session>\n";

    require Plack::Middleware::Session;
    return  Plack::Middleware::Session->wrap($app,
        store => $store,
        state => $state,
    );
}

sub load_controllers {
    my $self = shift;

    for my $method (keys %{ $self->{router}{rules} }) {
        for my $rule (@{ $self->{router}{rules}{$method} }) {
            my ($controller, $action) = ($rule->{controller}, $rule->{action});

            eval { Aqua::Util->require($controller) };
            if (my $e = $@) {
                $e =~ s/[\r\n]/\n\t/g; # indent error message
                Carp::croak "Can't locate <$controller> in \@INC:\n\t$e";
            }

            unless ($controller->can($action)) {
                Carp::croak "<$controller#$action> is not callable."
            }

            AQUA_DEBUG && print STDERR "Loaded <$controller#$action>\n";
        }
    }
}

1;
__END__

