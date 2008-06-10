#!perl

use strict;
use warnings;
use Test::More tests => 25;
use UFL::WebAdmin::SiteDeploy::Site;

BEGIN {
    use_ok('UFL::WebAdmin::SiteDeploy::Repository::SVN');
}

my $site = UFL::WebAdmin::SiteDeploy::Site->new(uri => 'http://www.ufl.edu/');

# file repository URI
{
    my $repo = UFL::WebAdmin::SiteDeploy::Repository::SVN->new(uri => 'file:///var/svn/repos/websites');

    isa_ok($repo, 'UFL::WebAdmin::SiteDeploy::Repository::SVN');
    isa_ok($repo, 'UFL::WebAdmin::SiteDeploy::Repository');

    isa_ok($repo->uri, 'URI::file');
    is($repo->uri, 'file:///var/svn/repos/websites', 'URI is file:///var/svn/repos/websites');
    is($repo->uri->path, '/var/svn/repos/websites', 'path translated from URI is /var/www/repos/websites');

    isa_ok($repo->client, 'SVN::Client');

    my $src = $repo->_source_uri($site);
    isa_ok($src, 'URI::file');
    isa_ok($src, 'URI');
    is($src, 'file:///var/svn/repos/websites/www.ufl.edu/trunk', 'source URI matches');

    my $dst = $repo->_destination_uri($site);
    isa_ok($dst, 'URI::file');
    isa_ok($dst, 'URI');
    like($dst, qr|file:///var/svn/repos/websites/www.ufl.edu/tags/\d{12}|, 'destination URI matches');
}

# https repository URI
{
    my $repo = UFL::WebAdmin::SiteDeploy::Repository::SVN->new(uri => 'https://svn.webadmin.ufl.edu/repos/websites/');

    isa_ok($repo, 'UFL::WebAdmin::SiteDeploy::Repository::SVN');
    isa_ok($repo, 'UFL::WebAdmin::SiteDeploy::Repository');

    isa_ok($repo->uri, 'URI::https');
    is($repo->uri, 'https://svn.webadmin.ufl.edu/repos/websites/', 'URI is https://svn.webadmin.ufl.edu/repos/websites/');
    is($repo->uri->path, '/repos/websites/', 'path translated from URI is /repos/websites/');

    isa_ok($repo->client, 'SVN::Client');

    my $src = $repo->_source_uri($site);
    isa_ok($src, 'URI::https');
    isa_ok($src, 'URI');
    is($src, 'https://svn.webadmin.ufl.edu/repos/websites/www.ufl.edu/trunk', 'source URI matches');

    my $dst = $repo->_destination_uri($site);
    isa_ok($dst, 'URI::https');
    isa_ok($dst, 'URI');
    like($dst, qr|https://svn.webadmin.ufl.edu/repos/websites/www.ufl.edu/tags/\d{12}|, 'destination URI matches');
}
