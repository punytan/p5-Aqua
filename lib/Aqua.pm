package Aqua;
use sane;
our $VERSION = '0.04';

1;
__END__

=head1 NAME

Aqua -

=head1 SYNOPSIS

  use Aqua;

  my $aqua = Aqua->new(router => $router);
  $aqua->load_controllers;

  my $app = $aqua->raw_app;

  # wrap app by inner middleware
  use MyApp::Middleware::Foo;
  $app = MyApp::Middleware::Foo->wrap($app);

  # wrap app by default middleware
  $app = Aqua->wrap_default_middlewares($app, {});

  # build my app
  use Plack::Builder;
  builder {
    enable "LogDispatch", logger => $logger;
    $app;
  };

=head1 DESCRIPTION

Aqua is

=head1 AUTHOR

punytan E<lt>punytan@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
