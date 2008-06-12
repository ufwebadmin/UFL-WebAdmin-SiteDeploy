#!perl

use strict;
use warnings;
use FindBin;
use Path::Class;
use SVN::Client;
use Test::More tests => 29;
use UFL::WebAdmin::SiteDeploy::Site;
use UFL::WebAdmin::SiteDeploy::TestRepository;

BEGIN {
    use_ok('UFL::WebAdmin::SiteDeploy::Repository::SVN');
}

my $TEST_REPO = UFL::WebAdmin::SiteDeploy::TestRepository->new;

$TEST_REPO->init;

my $REPO_DIR = $TEST_REPO->repository_dir;
my $REPO_URI = $TEST_REPO->repository_uri;
diag("repo_dir = [$REPO_DIR], repo_uri = [$REPO_URI]");

my $SITE = UFL::WebAdmin::SiteDeploy::Site->new(uri => 'http://www.ufl.edu/');

# file repository URI
{
    my $repo = UFL::WebAdmin::SiteDeploy::Repository::SVN->new(uri => $REPO_URI);

    isa_ok($repo, 'UFL::WebAdmin::SiteDeploy::Repository::SVN');
    isa_ok($repo, 'UFL::WebAdmin::SiteDeploy::Repository');

    isa_ok($repo->uri, 'URI::file');
    is($repo->uri, $REPO_URI, 'URI is correct');
    is($repo->uri->path, $REPO_DIR, 'path translated from URI is correct');

    isa_ok($repo->client, 'SVN::Client');

    my $entries = $repo->entries;
    is(scalar keys %$entries, 3, 'repository contains three items in the root directory');

    my $src = $repo->_source_uri($SITE);
    isa_ok($src, 'URI::file');
    isa_ok($src, 'URI');
    is($src, "$REPO_URI/www.ufl.edu/trunk", 'source URI matches');

    my $dst = $repo->_destination_uri($SITE);
    isa_ok($dst, 'URI::file');
    isa_ok($dst, 'URI');
    like($dst, qr|$REPO_URI/www.ufl.edu/tags/\d{12}|, 'destination URI matches');

    my $client = SVN::Client->new;
    my $current_tags = $client->ls("$REPO_URI/www.ufl.edu/tags", 'HEAD', 0);
    is(scalar keys %$current_tags, 2, 'tags directory currently contains two tags');

    $repo->deploy_site($SITE, 13, "Deploying " . $SITE->uri . " on behalf of dwc");

    my $new_tags = $client->ls("$REPO_URI/www.ufl.edu/tags", 'HEAD', 0);
    is(scalar keys %$new_tags, 3, 'tags directory currently now contains three tags');

    my $newest_tag = (sort keys %$new_tags)[2];

    my $log;
    $client->log([ "$REPO_URI/www.ufl.edu/tags/$newest_tag" ], 14, 14, 0, 0, sub { $log = $_[4] });
    is($log, 'Deploying http://www.ufl.edu/ on behalf of dwc', 'log message is correct');
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

    my $src = $repo->_source_uri($SITE);
    isa_ok($src, 'URI::https');
    isa_ok($src, 'URI');
    is($src, 'https://svn.webadmin.ufl.edu/repos/websites/www.ufl.edu/trunk', 'source URI matches');

    my $dst = $repo->_destination_uri($SITE);
    isa_ok($dst, 'URI::https');
    isa_ok($dst, 'URI');
    like($dst, qr|https://svn.webadmin.ufl.edu/repos/websites/www.ufl.edu/tags/\d{12}|, 'destination URI matches');
}
