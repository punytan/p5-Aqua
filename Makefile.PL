use inc::Module::Install;
name 'Aqua';
all_from 'lib/Aqua.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
