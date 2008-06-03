#!perl

use strict;
use warnings;
use File::Path ();
use File::Spec;
use FindBin;
use Log::Log4perl;
use Test::Log4perl;
use Test::More;

BEGIN {
    plan skip_all => "set TEST_AUTHOR to run these tests"
        unless $ENV{TEST_AUTHOR};
    plan tests => 5 + 4*10;

    use_ok('SVN::Notify::Mirror::Rsync::AutoCheckout');
}

my $REPO_DIR     = File::Spec->join($FindBin::Bin, 'data', 'repo');
my $SCRATCH_DIR  = File::Spec->join($FindBin::Bin, 'var');
my $CHECKOUT_DIR = File::Spec->join($SCRATCH_DIR, 'checkout');
my $RSYNC_DIR    = File::Spec->join($SCRATCH_DIR, 'rsync');
diag("repo_dir = [$REPO_DIR], checkout_dir = [$CHECKOUT_DIR], rsync_dir = [$RSYNC_DIR]");

my $DEFAULT_RSYNC_HOSTNAME = qx{hostname -f};
chomp $DEFAULT_RSYNC_HOSTNAME;
my %NOTIFIER_ARGS = (
    repos_path  => $REPO_DIR,
    to          => $CHECKOUT_DIR,
    revision    => 15,
    rsync_ssh   => 1,
    rsync_host  => $ENV{TEST_RSYNC_HOSTNAME} || $DEFAULT_RSYNC_HOSTNAME,
    rsync_dest  => $RSYNC_DIR,
    rsync_args  => { recursive => 1 },
    log_category => 'unit_svn_notify_mirror_rsync_autocheckout',
);

Log::Log4perl->init(\qq[
    log4perl.category.$NOTIFIER_ARGS{log_category} = DEBUG, Screen
    log4perl.appender.Screen = Log::Log4perl::Appender::Screen
    log4perl.appender.Screen.layout = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.Screen.layout.ConversionPattern = %c %p %l %m%n
]);

# Fresh checkout
File::Path::rmtree($SCRATCH_DIR) if -d $SCRATCH_DIR;
ok(! -d $CHECKOUT_DIR, 'checkout directory does not exist');

run_tests(
    $SCRATCH_DIR,
    $CHECKOUT_DIR,
    $RSYNC_DIR,
    [ 'test.txt' ],
    "file://$REPO_DIR/trunk/htdocs",
    {
        %NOTIFIER_ARGS,
        repos_uri  => "file://$REPO_DIR/trunk/htdocs",
    },
);

# Switched checkout
ok(-d $CHECKOUT_DIR, 'checkout directory exists');

run_tests(
    $SCRATCH_DIR,
    $CHECKOUT_DIR,
    $RSYNC_DIR,
    [ 'test2.txt' ],
    "file://$REPO_DIR/branches/test/htdocs",
    {
        %NOTIFIER_ARGS,
        repos_uri  => "file://$REPO_DIR/branches/test/htdocs",
    },
);

# Using tags with a suffix
File::Path::rmtree($SCRATCH_DIR) if -d $SCRATCH_DIR;
ok(! -d $CHECKOUT_DIR, 'checkout directory does not exist');

# Initial checkout
run_tests(
    $SCRATCH_DIR,
    $CHECKOUT_DIR,
    $RSYNC_DIR,
    [ 'test.txt' ],
    "file://$REPO_DIR/tags/200805291436/htdocs",
    {
        %NOTIFIER_ARGS,
        revision    => 9,
        tag_pattern => qr|tags/\d{12}|,
        repos_uri   => "file://$REPO_DIR/tags/200805291436/htdocs",
    },
);

ok(-d $CHECKOUT_DIR, 'checkout directory exists');

# Switching to new tag
run_tests(
    $SCRATCH_DIR,
    $CHECKOUT_DIR,
    $RSYNC_DIR,
    [ 'index.html' ],
    "file://$REPO_DIR/tags/200805291452/htdocs",
    {
        %NOTIFIER_ARGS,
        tag_pattern => qr|tags/\d{12}|,
        repos_uri   => "file://$REPO_DIR/tags/200805291436/htdocs",
    },
);


sub run_tests {
    my ($scratch_dir, $checkout_dir, $rsync_dir, $files, $repos_uri, $args) = @_;

    my $notifier = SVN::Notify::Mirror::Rsync::AutoCheckout->new(%$args);

    isa_ok($notifier, 'SVN::Notify::Mirror::Rsync::AutoCheckout');
    isa_ok($notifier, 'SVN::Notify::Mirror::Rsync');
    isa_ok($notifier, 'SVN::Notify::Mirror');
    isa_ok($notifier, 'SVN::Notify');

    ok($notifier->prepare, 'prepared AutoCheckout');

    # Close STDOUT avoid confusion in Test::Harness with the svn output
    close STDOUT or die "Could not close STDOUT: $!";

    my $test_logger = Test::Log4perl->get_logger($notifier->log_category);
    Test::Log4perl->start(ignore_priority => 'debug');
    $test_logger->info("Mirroring $repos_uri, revision $args->{revision}");
    $notifier->execute;
    Test::Log4perl->end("handler logged some basic information");

    # Reopen STDOUT to restore standard expectations
    open STDOUT, '>-' or die "Could not reopen STDOUT: $!";

    ok(-d $checkout_dir, 'checkout directory exists');
    ok(-d $rsync_dir, 'rsync directory exists');

    for my $file (@$files) {
        ok(-f File::Spec->join($checkout_dir, $file), "checkout directory contains checkout file $file");
        ok(-f File::Spec->join($rsync_dir, $file), "rsync directory contains checkout file $file");
    }
}
