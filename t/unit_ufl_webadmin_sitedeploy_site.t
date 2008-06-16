#!perl

use strict;
use warnings;
use Test::More tests => 19;
use UFL::WebAdmin::SiteDeploy::Repository::SVN;
use UFL::WebAdmin::SiteDeploy::TestRepository;
use URI::file;

BEGIN {
    use_ok('UFL::WebAdmin::SiteDeploy::Site');
}

my $TEST_REPO = UFL::WebAdmin::SiteDeploy::TestRepository->new;

my $REPO_DIR = $TEST_REPO->repository_dir;
my $REPO_URI = $TEST_REPO->repository_uri;
diag("repo_dir = [$REPO_DIR], repo_uri = [$REPO_URI]");

$TEST_REPO->init;
my $REPO = UFL::WebAdmin::SiteDeploy::Repository::SVN->new(uri => $REPO_URI);

{
    my $site = UFL::WebAdmin::SiteDeploy::Site->new(
        uri => 'http://www.ufl.edu/',
        repository => $REPO,
    );

    isa_ok($site, 'UFL::WebAdmin::SiteDeploy::Site');

    isa_ok($site->uri, 'URI::http');
    is($site->uri, 'http://www.ufl.edu/', 'URI matches');
    is($site->uri->host, 'www.ufl.edu', 'host matches');
    is($site->uri->path, '/', 'path matches');

    is($site->identifier, 'www.ufl.edu', 'site identifier is correct');

    isa_ok($site->repository, 'UFL::WebAdmin::SiteDeploy::Repository::SVN');

    my $current_tags = $site->prod_entries;
    is(scalar keys %$current_tags, 2, 'tags directory currently contains two tags');

    $site->deploy(13, "Deploying " . $site->uri . " on behalf of dwc");

    my $new_tags = $site->prod_entries;
    is(scalar keys %$new_tags, 3, 'tags directory currently now contains three tags');

    my $newest_tag = (sort keys %$new_tags)[2];

    my $client = SVN::Client->new;
    my $log;
    $client->log([ "$REPO_URI/www.ufl.edu/tags/$newest_tag" ], 14, 14, 0, 0, sub { $log = $_[4] });
    is($log, 'Deploying http://www.ufl.edu/ on behalf of dwc', 'log message is correct');
}

{
    my $site = UFL::WebAdmin::SiteDeploy::Site->new(
        uri => 'http://this-does-not-exist.ufl.edu',
        repository => $REPO,
    );

    isa_ok($site, 'UFL::WebAdmin::SiteDeploy::Site');

    isa_ok($site->uri, 'URI::http');
    is($site->uri, 'http://this-does-not-exist.ufl.edu', 'URI matches');
    is($site->uri->host, 'this-does-not-exist.ufl.edu', 'host matches');
    is($site->uri->path, '', 'path matches');

    is($site->identifier, 'this-does-not-exist.ufl.edu', 'site identifier is correct');

    isa_ok($site->repository, 'UFL::WebAdmin::SiteDeploy::Repository::SVN');

    eval {
        $site->deploy(13, "Deploying site")
    };
    like($@, qr/^Filesystem has no item/, 'got an error message for a nonexistent site');
}
