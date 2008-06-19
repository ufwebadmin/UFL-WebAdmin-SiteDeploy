#!perl

use strict;
use warnings;
use Test::More tests => 47;
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

    isa_ok($site->project, 'VCI::VCS::Svn::Project');
    isa_ok($site->project, 'VCI::Abstract::Project');

    is($site->id, 'www.ufl.edu', 'project identifier matches');

    isa_ok($site->uri, 'URI::http');
    is($site->uri, 'http://www.ufl.edu/', 'URI matches');
    is($site->uri->host, 'www.ufl.edu', 'host matches');
    is($site->uri->path, '/', 'path matches');

    # XXX: Calling head_revision seems to change what we get for update_commits and deploy_commits
    is($site->project->head_revision, 8, 'project head revision is correct');

    my $update_history = $site->update_history;
    isa_ok($update_history, 'VCI::VCS::Svn::History');
    isa_ok($update_history, 'VCI::Abstract::History');

    my $update_commits = $site->update_commits;
    is(scalar @$update_commits, 3, 'found three update commits');
    isa_ok($update_commits->[0], 'VCI::VCS::Svn::Commit');
    isa_ok($update_commits->[0], 'VCI::Abstract::Commit');

    my $deploy_history = $site->deploy_history;
    isa_ok($deploy_history, 'VCI::VCS::Svn::History');
    isa_ok($deploy_history, 'VCI::Abstract::History');

    my $deploy_commits = $site->deploy_commits;
    is(scalar @$deploy_commits, 2, 'found two deploy commits');
    isa_ok($deploy_commits->[0], 'VCI::VCS::Svn::Commit');
    isa_ok($deploy_commits->[0], 'VCI::Abstract::Commit');

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
    ok(! $site->has_outstanding_changes, 'site does not have any outstanding changes before deploy');

    my $current_tags = $site->deployments;
    is(scalar @$current_tags, 2, 'tags directory currently contains two tags');

    $site->deploy(13, "Deploying " . $site->id . " on behalf of dwc");
    eval { $site->deploy(13, "Deploying " . $site->id . " on behalf of dwc") };
    like($@, qr/^Site has already been deployed/, 'got an error message on duplicate deploy times');

    my $new_tags = $site->deployments;
    is(scalar @$new_tags, 3, 'tags directory now contains three tags');

    is($site->project->head_revision, 14, 'project head revision after deploy is correct');
    is(scalar @{ $site->deploy_commits }, 3, 'found three deploy commits');

    is($site->last_update->message, 'Add another file', 'log message for most recent update is correct');
    is($site->last_deployment->message, 'Deploying www.ufl.edu on behalf of dwc', 'log message for most recent deployment is correct');

    ok(! $site->has_outstanding_changes, 'site does not have any outstanding changes adter deploy');
}

# Site with outstanding changes
{
    my $project = $REPO->get_project(name => 'www.webadmin.ufl.edu');
    my $site = UFL::WebAdmin::SiteDeploy::Site->new(
        project => $project,
    );

    isa_ok($site, 'UFL::WebAdmin::SiteDeploy::Site');

    ok($site->has_outstanding_changes, 'site has outstanding changes before deploy');
    $site->deploy(13, "Deploying " . $site->id . " on behalf of dwc");
    ok(! $site->has_outstanding_changes, 'site does not have any outstanding changes adter deploy');
}

# Nonexistent site
{
    my $project = $REPO->get_project(name => 'this-does-not-exist.ufl.edu');
    my $site = UFL::WebAdmin::SiteDeploy::Site->new(
        project => $project,
    );

    isa_ok($site, 'UFL::WebAdmin::SiteDeploy::Site');

    is($site->id, 'this-does-not-exist.ufl.edu', 'project identifier matches');

    isa_ok($site->project, 'VCI::VCS::Svn::Project');
    isa_ok($site->project, 'VCI::Abstract::Project');

    isa_ok($site->uri, 'URI::http');
    is($site->uri, 'http://this-does-not-exist.ufl.edu/', 'URI matches');
    is($site->uri->host, 'this-does-not-exist.ufl.edu', 'host matches');
    is($site->uri->path, '/', 'path matches');

    # Test an invalid deploy operation
    eval {
        $site->deploy(13, "Deploying site")
    };
    like($@, qr/^Filesystem has no item/, 'got an error message for a nonexistent site');
}
