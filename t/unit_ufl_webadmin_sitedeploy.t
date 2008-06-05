#!perl

use strict;
use warnings;
use File::Path;
use File::Spec;
use FindBin;
use Test::More tests => 4 + 2*2 + 2 + 4;

BEGIN {
    use_ok('UFL::WebAdmin::SiteDeploy');
}

my $REPO_DIR     = File::Spec->join($FindBin::Bin, 'data', 'repo');
my $SCRATCH_DIR  = File::Spec->join($FindBin::Bin, 'var');
my $MIRROR_DIR = File::Spec->join($SCRATCH_DIR, 'mirror');
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
    create_checkout('trunk/htdocs', 13);
    ok(! -f File::Spec->join($MIRROR_DIR, 'index.html'), 'mirror directory does not contain checkout file index.html');

    local @ARGV = ('deploy', '--path', $REPO_DIR, '--revision', 17);

    eval { $app->run };
    ok(! $@, 'successfully ran no-op deploy command');
}

# Test a real deploy
{
    no warnings 'redefine';

    create_checkout('trunk/htdocs', 13);
    ok(! -f File::Spec->join($MIRROR_DIR, 'index.html'), 'mirror directory does not contain checkout file index.html');

    local @ARGV = ('deploy', '--path', $REPO_DIR, '--revision', 14);

    # Override _load_config to provide a mirror path that we can throw
    # out at the end of the tests
    local *UFL::WebAdmin::SiteDeploy::Command::deploy::_load_config = sub {
        return {
            'trunk/htdocs' => {
                handler => 'Mirror',
                to      => $MIRROR_DIR,
            },
        };
    };

    eval { $app->run };
    ok(! $@, 'successfully ran a deploy command');
    ok(-d $MIRROR_DIR, 'mirror directory created');
    ok(-f File::Spec->join($MIRROR_DIR, 'index.html'), 'mirror directory contains checkout file index.html');
}


sub create_checkout {
    my ($path, $revision) = @_;

    File::Path::rmtree($SCRATCH_DIR) if -d $SCRATCH_DIR;
    ok(! -d $MIRROR_DIR, 'mirror directory does not exist');

    my $repo_path = File::Spec->join($REPO_DIR, $path);

    # Close STDOUT avoid confusion in Test::Harness with the svn output
    close STDOUT or die "Could not close STDOUT: $!";

    system('svn', 'checkout', '-r', $revision, "file://$repo_path", $MIRROR_DIR);

    # Reopen STDOUT to restore standard expectations
    open STDOUT, '>-' or die "Could not reopen STDOUT: $!";

    ok(-d $MIRROR_DIR, 'mirror directory created');
}
