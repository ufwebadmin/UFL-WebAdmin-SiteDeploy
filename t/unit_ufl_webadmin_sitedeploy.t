#!perl

use strict;
use warnings;
use File::Path;
use File::Spec;
use FindBin;
use Test::More tests => 5;

BEGIN {
    use_ok('UFL::WebAdmin::SiteDeploy');
}

my $REPO_DIR     = File::Spec->join($FindBin::Bin, 'data', 'repo');
my $SCRATCH_DIR  = File::Spec->join($FindBin::Bin, 'var');
my $CHECKOUT_DIR = File::Spec->join($SCRATCH_DIR, 'checkout');
diag("repo_dir = [$REPO_DIR], checkout_dir = [$CHECKOUT_DIR]");

File::Path::rmtree($SCRATCH_DIR) if -d $SCRATCH_DIR;
ok(! -d $CHECKOUT_DIR, 'checkout directory does not exist');

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

{
    local @ARGV = ('deploy', '--path', $REPO_DIR, '--revision', 16);

    $app->run;
}
