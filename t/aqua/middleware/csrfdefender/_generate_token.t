use sane;
use Test::More;

use Aqua::Middleware::CSRFDefender;

my $token = Aqua::Middleware::CSRFDefender->_generate_token;
like $token, qr/^[0-9a-f]{40}$/;

done_testing;
