#!perl

use strict;
use warnings;
use File::Path ();
use File::Spec;
use FindBin;
use Test::More tests => 11;

BEGIN {
      use_ok('SVN::Notify::Mirror::Rsync::AutoCreateCheckout');
}

my $repo_dir     = File::Spec->join($FindBin::Bin, 'data', 'repo');
my $scratch_dir  = File::Spec->join($FindBin::Bin, 'var');
my $checkout_dir = File::Spec->join($scratch_dir, 'checkout');
my $rsync_dir    = File::Spec->join($scratch_dir, 'rsync');
diag("repo_dir = [$repo_dir], checkout_dir = [$checkout_dir], rsync_dir = [$rsync_dir]");

File::Path::rmtree($scratch_dir) if -d $scratch_dir;

my $notifier = SVN::Notify::Mirror::Rsync::AutoCreateCheckout->new(
    repos_path => $repo_dir,
    repos_uri  => "file://$repo_dir",
    to         => $checkout_dir,
    revision   => 1,
    rsync_ssh  => 1,
    rsync_host => $ENV{TEST_RSYNC_HOSTNAME},
    rsync_dest => $rsync_dir,
    rsync_args => { recursive => 1 },
);

isa_ok($notifier, 'SVN::Notify::Mirror::Rsync::AutoCreateCheckout');
isa_ok($notifier, 'SVN::Notify::Mirror::Rsync');
isa_ok($notifier, 'SVN::Notify::Mirror');
isa_ok($notifier, 'SVN::Notify');

ok(! -d $checkout_dir, 'checkout directory does not exist');
ok($notifier->prepare, 'prepared AutoCreateCheckout');

SKIP: {
    skip "set TEST_AUTHOR and set TEST_RSYNC_HOSTNAME to something known in .ssh/known_hosts", 4
        unless $ENV{TEST_AUTHOR};

    # Close and the reopen STDOUT to avoid confusion in Test::Harness with the svn output
    close STDOUT or die "Could not close STDOUT: $!";
    $notifier->execute;
    open STDOUT, '>-' or die "Could not reopen STDOUT: $!";

    ok(-d $checkout_dir, 'checkout directory created');
    ok(-f File::Spec->join($checkout_dir, 'test.txt'), 'checkout directory contains checkout');

    ok(-d $rsync_dir, 'rsync directory created');
    ok(-f File::Spec->join($rsync_dir, 'test.txt'), 'rsync directory contains checkout');
}
