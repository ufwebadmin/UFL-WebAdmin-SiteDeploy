#!perl

use strict;
use warnings;
use Test::More tests => 11;

BEGIN {
    use_ok('UFL::WebAdmin::SiteDeploy::Site');
}

{
    my $site = UFL::WebAdmin::SiteDeploy::Site->new(uri => 'http://www.ufl.edu/');

    isa_ok($site, 'UFL::WebAdmin::SiteDeploy::Site');

    isa_ok($site->uri, 'URI::http');
    is($site->uri, 'http://www.ufl.edu/', 'URI matches');
    is($site->uri->host, 'www.ufl.edu', 'host matches');
    is($site->uri->path, '/', 'path matches');
}

{
    my $site = UFL::WebAdmin::SiteDeploy::Site->new(uri => 'http://test.www.ufl.edu');

    isa_ok($site, 'UFL::WebAdmin::SiteDeploy::Site');

    isa_ok($site->uri, 'URI::http');
    is($site->uri, 'http://test.www.ufl.edu', 'URI matches');
    is($site->uri->host, 'test.www.ufl.edu', 'host matches');
    is($site->uri->path, '', 'path matches');
}
