use sane;
use Test::More;

BEGIN {
    use_ok 'Aqua';
    use_ok 'Aqua::Handler';
    use_ok 'Aqua::Util';

    use_ok 'Aqua::Middleware::ErrorDocument';
    use_ok 'Aqua::Middleware::SecureHeader';
    use_ok 'Aqua::Middleware::CSRFDefender';

}

done_testing;
