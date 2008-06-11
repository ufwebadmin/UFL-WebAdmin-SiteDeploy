#!perl

use strict;
use warnings;
use FindBin;
use Log::Log4perl;
use Path::Class;
use Test::Log4perl;
use Test::More;
use UFL::WebAdmin::SiteDeploy::TestRepository;
use URI::file;

BEGIN {
    plan skip_all => "set TEST_AUTHOR to run these tests"
        unless $ENV{TEST_AUTHOR};
    plan tests => 5 + 4*10;

    use_ok('SVN::Notify::Mirror::Rsync::AutoCheckout');
}

my $TEST_REPO = UFL::WebAdmin::SiteDeploy::TestRepository->new(
    base      => $FindBin::Bin,
    dump_file => file($FindBin::Bin, 'data', 'repo.dump'),
);

my $REPO_DIR     = $TEST_REPO->repository_dir;
my $REPO_URI     = URI::file->new($REPO_DIR);
my $CHECKOUT_DIR = $TEST_REPO->checkout_dir;
my $RSYNC_DIR    = $TEST_REPO->scratch_dir->subdir('rsync');
diag("repo_dir = [$REPO_DIR], repo_uri = [$REPO_URI], checkout_dir = [$CHECKOUT_DIR], rsync_dir = [$RSYNC_DIR]");

my $DEFAULT_RSYNC_HOSTNAME = qx{hostname -f};
chomp $DEFAULT_RSYNC_HOSTNAME;
my %NOTIFIER_ARGS = (
    repos_path   => $REPO_DIR->stringify,
    to           => $CHECKOUT_DIR->stringify,
    revision     => 12,
    rsync_ssh    => 1,
    rsync_host   => $ENV{TEST_RSYNC_HOSTNAME} || $DEFAULT_RSYNC_HOSTNAME,
    rsync_dest   => $RSYNC_DIR->stringify,
    rsync_args   => { recursive => 1 },
    log_category => 'unit_svn_notify_mirror_rsync_autocheckout',
);

Log::Log4perl->init(\qq[
    log4perl.category.$NOTIFIER_ARGS{log_category} = DEBUG, Screen
    log4perl.appender.Screen = Log::Log4perl::Appender::Screen
    log4perl.appender.Screen.layout = Log::Log4perl::Layout::PatternLayout
    log4perl.appender.Screen.layout.ConversionPattern = %c %p %l %m%n
]);

$TEST_REPO->init;
ok(! -d $CHECKOUT_DIR, 'checkout directory does not exist');

# Fresh checkout
run_tests(
    $CHECKOUT_DIR,
    $RSYNC_DIR,
    [ 'test.txt' ],
    "$REPO_URI/www.ufl.edu/trunk/htdocs",
    {
        %NOTIFIER_ARGS,
        repos_uri  => "$REPO_URI/www.ufl.edu/trunk/htdocs",
    },
);

# Switched checkout
ok(-d $CHECKOUT_DIR, 'checkout directory exists');

run_tests(
    $CHECKOUT_DIR,
    $RSYNC_DIR,
    [ 'test2.txt' ],
    "$REPO_URI/www.ufl.edu/branches/test/htdocs",
    {
        %NOTIFIER_ARGS,
        repos_uri  => "$REPO_URI/www.ufl.edu/branches/test/htdocs",
    },
);

# Using tags with a suffix
$TEST_REPO->init;
ok(! -d $CHECKOUT_DIR, 'checkout directory does not exist');

# Initial checkout
run_tests(
    $CHECKOUT_DIR,
    $RSYNC_DIR,
    [ 'test.txt' ],
    "$REPO_URI/www.ufl.edu/tags/200806111444/htdocs",
    {
        %NOTIFIER_ARGS,
        revision    => 4,
        tag_pattern => qr|tags/\d{12}|,
        repos_uri   => "$REPO_URI/www.ufl.edu/tags/200806111444/htdocs",
    },
);

ok(-d $CHECKOUT_DIR, 'checkout directory exists');

# Switching to new tag
run_tests(
    $CHECKOUT_DIR,
    $RSYNC_DIR,
    [ 'index.html' ],
    "$REPO_URI/www.ufl.edu/tags/200806111445/htdocs",
    {
        %NOTIFIER_ARGS,
        revision    => 6,
        tag_pattern => qr|tags/\d{12}|,
        repos_uri   => "$REPO_URI/www.ufl.edu/tags/200806111444/htdocs",
    },
);


sub run_tests {
    my ($checkout_dir, $rsync_dir, $files, $repos_uri, $args) = @_;

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
        ok(-f $checkout_dir->file($file), "checkout directory contains checkout file $file");
        ok(-f $rsync_dir->file($file), "rsync directory contains checkout file $file");
    }
}
