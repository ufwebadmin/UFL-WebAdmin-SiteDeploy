#!perl

use strict;
use warnings;
use FindBin;
use Path::Class;
use Test::More tests => 17;
use UFL::WebAdmin::SiteDeploy::Repository::SVN;
use UFL::WebAdmin::SiteDeploy::TestRepository;
use URI::file;

BEGIN {
    use_ok('UFL::WebAdmin::SiteDeploy::Site');
}

my $TEST_REPO = UFL::WebAdmin::SiteDeploy::TestRepository->new(
    base      => $FindBin::Bin,
    dump_file => file($FindBin::Bin, 'data', 'repo.dump'),
);

my $REPO_DIR = $TEST_REPO->repository_dir;
my $REPO_URI = URI::file->new($REPO_DIR);
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

    isa_ok($site->repository, 'UFL::WebAdmin::SiteDeploy::Repository::SVN');

    my $client = SVN::Client->new;
    my $current_tags = $client->ls("$REPO_URI/www.ufl.edu/tags", 'HEAD', 0);
    is(scalar keys %$current_tags, 2, 'tags directory currently contains two tags');

    $site->deploy(13, "Deploying " . $site->uri . " on behalf of dwc");

    my $new_tags = $client->ls("$REPO_URI/www.ufl.edu/tags", 'HEAD', 0);
    is(scalar keys %$new_tags, 3, 'tags directory currently now contains three tags');

    my $newest_tag = (sort keys %$new_tags)[2];

    my $log;
    $client->log([ "$REPO_URI/www.ufl.edu/tags/$newest_tag" ], 14, 14, 0, 0, sub { $log = $_[4] });
    is($log, 'Deploying http://www.ufl.edu/ on behalf of dwc', 'log message is correct');
}

{
    my $site = UFL::WebAdmin::SiteDeploy::Site->new(
        uri => 'http://test.www.ufl.edu',
        repository => $REPO,
    );

    isa_ok($site, 'UFL::WebAdmin::SiteDeploy::Site');

    isa_ok($site->uri, 'URI::http');
    is($site->uri, 'http://test.www.ufl.edu', 'URI matches');
    is($site->uri->host, 'test.www.ufl.edu', 'host matches');
    is($site->uri->path, '', 'path matches');

    isa_ok($site->repository, 'UFL::WebAdmin::SiteDeploy::Repository::SVN');

    eval {
        $site->deploy(13, "Deploying site")
    };
    like($@, qr/^Filesystem has no item/, 'got an error message for a nonexistent site');
}
