#!perl

use strict;
use warnings;
use Test::More tests => 11;
use UFL::WebAdmin::SiteDeploy::Site;

BEGIN {
    use_ok('UFL::WebAdmin::SiteDeploy::Repository');
}

my $SITE = UFL::WebAdmin::SiteDeploy::Site->new(uri => 'http://www.ufl.edu/');

# file repository URI
{
    my $repo = UFL::WebAdmin::SiteDeploy::Repository->new(uri => 'file:///var/svn/repos/websites');

    isa_ok($repo, 'UFL::WebAdmin::SiteDeploy::Repository');

    isa_ok($repo->uri, 'URI::file');
    is($repo->uri, 'file:///var/svn/repos/websites', 'URI is file:///var/svn/repos/websites');
    is($repo->uri->path, '/var/svn/repos/websites', 'path translated from URI is /var/www/repos/websites');

    eval { $repo->deploy_site($SITE, 1, "Deploying on behalf of dwc") };
    like($@, qr/^abstract method/, 'calling deploy_site fails because it is an abstract method');
}

# https repository URI
{
    my $repo = UFL::WebAdmin::SiteDeploy::Repository->new(uri => 'https://svn.webadmin.ufl.edu/repos/websites/');

    isa_ok($repo, 'UFL::WebAdmin::SiteDeploy::Repository');

    isa_ok($repo->uri, 'URI::https');
    is($repo->uri, 'https://svn.webadmin.ufl.edu/repos/websites/', 'URI is https://svn.webadmin.ufl.edu/repos/websites/');
    is($repo->uri->path, '/repos/websites/', 'path translated from URI is /repos/websites/');

    eval { $repo->deploy_site($SITE, 1, "Deploying on behalf of dwc") };
    like($@, qr/^abstract method/, 'calling deploy_site fails because it is an abstract method');
}
