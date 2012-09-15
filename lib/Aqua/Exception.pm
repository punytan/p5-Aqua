package Aqua::Exception;
use sane;
use HTTP::Status;

use overload '""' => sub { shift->as_string }, fallback => 1;

sub new {
    my ($class, $code, $body, $header) = @_;
    bless {
        code   => $code,
        body   => $body,
        header => $header,
    }, $class;
}

sub code   { shift->{code}   || 500 }
sub body   { shift->{body}   || []  }
sub header { shift->{header} || []  }

sub throw {
    my ($class, @rest) = @_;
    die $class->new(@rest);
}

sub as_string {
    my ($self) = @_;
    my $code = $self->code || 500;
    my $body = join "", @{$self->body} || HTTP::Status::status_message($code);
    return "$code $body";
}

1;
__END__
