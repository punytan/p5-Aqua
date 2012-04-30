package Aqua::Middleware::CSRFDefender;
use sane;
use parent 'Plack::Middleware';
use Plack::Request;
use Plack::Session;
use Digest::SHA1;
use Carp;
use Plack::Util::Accessor qw( error_message );

sub call {
    my ($self, $env) = @_;

    if (not defined $env->{'psgix.session'}) {
        Carp::croak "Fatal: enable session middlware before CSRFDefender";
    }

    my $request = Plack::Request->new($env);
    my $session = Plack::Session->new($env);
    my $method  = uc $request->method;

    my $res;

    if ($method eq 'HEAD' || $method eq 'GET') {
        unless ($session->get("csrf_token")) {
            $session->set("csrf_token", $self->_generate_token);
        }

        $res = $self->app->($env);

    } else {
        my $server_token = $session->get("csrf_token");
        my $client_token = $request->body_parameters->{csrf_token};

        if ($server_token && $client_token && $server_token eq $client_token) {
            $res = $self->app->($env);

        } else {
            my $body = $self->error_message
                ? [ $self->error_message ]
                : [];
            $res = [403, [], $body]; # 403 Forbidden
        }

    }

    return $res;

}

sub _generate_token { Digest::SHA1::sha1_hex(rand() . $$ . {} . time) }

1;
__END__
