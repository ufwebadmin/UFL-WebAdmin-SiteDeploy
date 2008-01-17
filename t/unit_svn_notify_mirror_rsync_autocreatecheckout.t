#!perl

use strict;
use warnings;
use Cwd ();
use File::Path ();
use File::Spec;
use FindBin;
use Test::More;

BEGIN {
    plan skip_all => "set TEST_AUTHOR and set TEST_RSYNC_HOSTNAME to something corresponding to localhost that is listed in .ssh/known_hosts"
        unless $ENV{TEST_AUTHOR};
    plan tests => 21;

    use_ok('SVN::Notify::Mirror::Rsync::AutoCreateCheckout');
}

my $REPO_DIR     = File::Spec->join($FindBin::Bin, 'data', 'repo');
my $SCRATCH_DIR  = File::Spec->join($FindBin::Bin, 'var');
my $CHECKOUT_DIR = File::Spec->join($SCRATCH_DIR, 'checkout');
my $RSYNC_DIR    = File::Spec->join($SCRATCH_DIR, 'rsync');
diag("repo_dir = [$REPO_DIR], checkout_dir = [$CHECKOUT_DIR], rsync_dir = [$RSYNC_DIR]");

my %NOTIFIER_ARGS = (
    repos_path => $REPO_DIR,
    to         => $CHECKOUT_DIR,
    revision   => 6,
    rsync_ssh  => 1,
    rsync_host => $ENV{TEST_RSYNC_HOSTNAME},
    rsync_dest => $RSYNC_DIR,
    rsync_args => { recursive => 1 },
);

# Fresh checkout
File::Path::rmtree($SCRATCH_DIR) if -d $SCRATCH_DIR;
ok(! -d $CHECKOUT_DIR, 'checkout directory does not exist');

run_tests(
    $SCRATCH_DIR,
    $CHECKOUT_DIR,
    $RSYNC_DIR,
    [ 'test.txt' ],
    {   
        %NOTIFIER_ARGS,
        repos_uri  => "file://$REPO_DIR/trunk",
    },
);

# Switched checkout
ok(-d $CHECKOUT_DIR, 'checkout directory exists');

run_tests(
    $SCRATCH_DIR,
    $CHECKOUT_DIR,
    $RSYNC_DIR,
    [ 'test2.txt' ],
    {   
        %NOTIFIER_ARGS,
        repos_uri  => "file://$REPO_DIR/branches/test",
    },
);

sub run_tests {
    my ($scratch_dir, $checkout_dir, $rsync_dir, $files, $args) = @_;

    my $cwd = Cwd::getcwd();

    my $notifier = SVN::Notify::Mirror::Rsync::AutoCreateCheckout->new(%$args);

    isa_ok($notifier, 'SVN::Notify::Mirror::Rsync::AutoCreateCheckout');
    isa_ok($notifier, 'SVN::Notify::Mirror::Rsync');
    isa_ok($notifier, 'SVN::Notify::Mirror');
    isa_ok($notifier, 'SVN::Notify');

    ok($notifier->prepare, 'prepared AutoCreateCheckout');

    # Close and the reopen STDOUT to avoid confusion in Test::Harness with the svn output
    close STDOUT or die "Could not close STDOUT: $!";
    $notifier->execute;
    open STDOUT, '>-' or die "Could not reopen STDOUT: $!";

    ok(-d $checkout_dir, 'checkout directory exists');
    ok(-d $rsync_dir, 'rsync directory exists');

    for my $file (@$files) {
        ok(-f File::Spec->join($checkout_dir, $file), "checkout directory contains checkout file $file");
        ok(-f File::Spec->join($rsync_dir, $file), "rsync directory contains checkout file $file");
    }

    # Return to previous working directory (SVN::Notify::Mirror
    # doesn't, so subsequent tests fail, grr)
    chdir($cwd);
}
