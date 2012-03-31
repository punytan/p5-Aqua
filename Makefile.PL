use inc::Module::Install;
name 'Aqua';
all_from 'lib/Aqua.pm';

requires 'sane';
requires 'DBI';
requires 'DBD::SQLite';
requires 'Digest::SHA1';
requires 'HTTP::Status';
requires 'JSON::XS';
requires 'List::MoreUtils';
requires 'Text::MultiMarkdown';
requires 'JavaScript::Value::Escape';
requires 'Text::Xslate';
requires 'Router::Lazy';

requires 'Plack';
requires 'Plack::Session';

test_requires 'HTTP::Request::Common';
test_requires 'LWP::Protocol::PSGI';
test_requires 'LWP::UserAgent';

tests 't/*.t t/*/*.t t/*/*/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
