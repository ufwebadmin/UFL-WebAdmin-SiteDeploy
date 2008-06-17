#!perl

use strict;
use warnings;
use Test::More tests => 25;
use UFL::WebAdmin::SiteDeploy::TestRepository;
use URI::file;
use VCI;

BEGIN {
    use_ok('UFL::WebAdmin::SiteDeploy::Site');
}

my $TEST_REPO = UFL::WebAdmin::SiteDeploy::TestRepository->new;

my $REPO_DIR = $TEST_REPO->repository_dir;
my $REPO_URI = $TEST_REPO->repository_uri;
diag("repo_dir = [$REPO_DIR], repo_uri = [$REPO_URI]");

$TEST_REPO->init;
my $REPO = VCI->connect(type => 'Svn', repo => $REPO_URI->as_string);

{
    my $project = $REPO->get_project(name => 'www.ufl.edu');
    my $site = UFL::WebAdmin::SiteDeploy::Site->new(
        project => $project,
    );

    isa_ok($site, 'UFL::WebAdmin::SiteDeploy::Site');

    isa_ok($site->uri, 'URI::http');
    is($site->uri, 'http://www.ufl.edu/', 'URI matches');
    is($site->uri->host, 'www.ufl.edu', 'host matches');
    is($site->uri->path, '/', 'path matches');

    isa_ok($site->project, 'VCI::VCS::Svn::Project');
    isa_ok($site->project, 'VCI::Abstract::Project');

    # Test set up for deploy operation
    my $src = $site->_source_uri($site);
    isa_ok($src, 'URI::file');
    isa_ok($src, 'URI');
    is($src, "$REPO_URI/www.ufl.edu/trunk", 'source URI matches');

    my $dst = $site->_destination_uri($site);
    isa_ok($dst, 'URI::file');
    isa_ok($dst, 'URI');
    like($dst, qr|$REPO_URI/www.ufl.edu/tags/\d{12}|, 'destination URI matches');

    # Test deploy operation
    my $current_tags = $site->deployments;
    is(scalar @$current_tags, 2, 'tags directory currently contains two tags');

    $site->deploy(13, "Deploying " . $site->uri . " on behalf of dwc");

    my $new_tags = $site->deployments;
    is(scalar @$new_tags, 3, 'tags directory now contains three tags');
    is($site->last_deploy->message, 'Deploying http://www.ufl.edu/ on behalf of dwc', 'log message is correct');
}

{
    my $project = $REPO->get_project(name => 'this-does-not-exist.ufl.edu');
    my $site = UFL::WebAdmin::SiteDeploy::Site->new(
        project => $project,
    );

    isa_ok($site, 'UFL::WebAdmin::SiteDeploy::Site');

    isa_ok($site->uri, 'URI::http');
    is($site->uri, 'http://this-does-not-exist.ufl.edu/', 'URI matches');
    is($site->uri->host, 'this-does-not-exist.ufl.edu', 'host matches');
    is($site->uri->path, '/', 'path matches');

    isa_ok($site->project, 'VCI::VCS::Svn::Project');
    isa_ok($site->project, 'VCI::Abstract::Project');

    # Test an invalid deploy operation
    eval {
        $site->deploy(13, "Deploying site")
    };
    like($@, qr/^Filesystem has no item/, 'got an error message for a nonexistent site');
}
