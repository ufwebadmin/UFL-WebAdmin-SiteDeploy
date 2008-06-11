#!perl

use strict;
use warnings;
use FindBin;
use Path::Class;
use Test::More tests => 4 + 2*1 + 2 + 4;
use UFL::WebAdmin::SiteDeploy::TestRepository;

BEGIN {
    use_ok('UFL::WebAdmin::SiteDeploy');
}

my $TEST_REPO = UFL::WebAdmin::SiteDeploy::TestRepository->new(
    base      => $FindBin::Bin,
    dump_file => file($FindBin::Bin, 'data', 'repo.dump'),
);

$TEST_REPO->init;

my $REPO_DIR   = $TEST_REPO->repository_dir;
my $MIRROR_DIR = $TEST_REPO->scratch_dir->subdir('mirror');
diag("repo_dir = [$REPO_DIR], mirror_dir = [$MIRROR_DIR]");

my $app = UFL::WebAdmin::SiteDeploy->new;
isa_ok($app, 'UFL::WebAdmin::SiteDeploy');

is_deeply(
    [ sort $app->command_names ],
    [ sort qw(--help help -h -? commands deploy) ],
    'list of command names is correct',
);

is_deeply(
    [ sort $app->command_plugins ],
    [ sort qw(
        App::Cmd::Command::commands
        App::Cmd::Command::help
        UFL::WebAdmin::SiteDeploy::Command::deploy
    ) ],
    'list of command plugins is correct',
);

# Test loading a no-op config from the repository
{
    create_checkout('www.webadmin.ufl.edu/trunk/htdocs', 12);
    ok(! -f $MIRROR_DIR->file('foo.html'), 'mirror directory does not contain checkout file foo.html');

    local @ARGV = ('deploy', '--path', $REPO_DIR->stringify, '--revision', 13);

    eval { $app->run };
    diag($@) if $@;
    ok(! $@, 'successfully ran no-op deploy command');
}

# Test a real deploy
{
    no warnings 'redefine';

    create_checkout('www.webadmin.ufl.edu/trunk/htdocs', 12);
    ok(! -f $MIRROR_DIR->file('foo.html'), 'mirror directory does not contain checkout file foo.html');

    local @ARGV = ('deploy', '--path', $REPO_DIR->stringify, '--revision', 13);

    # Override _load_config to provide a mirror path that we can throw
    # out at the end of the tests
    local *UFL::WebAdmin::SiteDeploy::Command::deploy::_load_svn_notify_config = sub {
        return {
            'www.webadmin.ufl.edu/trunk/htdocs' => {
                handler => 'Mirror',
                to      => $MIRROR_DIR->stringify,
            },
        };
    };

    eval { $app->run };
    diag($@) if $@;
    ok(! $@, 'successfully ran a deploy command');
    ok(-d $MIRROR_DIR, 'mirror directory created');
    ok(-f $MIRROR_DIR->file('foo.html'), 'mirror directory contains checkout file foo.html');
}


sub create_checkout {
    my ($path, $revision) = @_;

    my $repo_path = $REPO_DIR->subdir($path);

    # Close STDOUT avoid confusion in Test::Harness with the svn
    # output from SVN::Notify::Mirror
    close STDOUT or die "Could not close STDOUT: $!";

    system('svn', 'checkout', '-r', $revision, "file://$repo_path", $MIRROR_DIR);

    # Reopen STDOUT to restore standard expectations
    open STDOUT, '>-' or die "Could not reopen STDOUT: $!";

    ok(-d $MIRROR_DIR, 'mirror directory created');
}
