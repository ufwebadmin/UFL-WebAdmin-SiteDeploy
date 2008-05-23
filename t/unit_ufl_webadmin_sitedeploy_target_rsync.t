#!perl

use strict;
use warnings;
use Test::More tests => 24;

BEGIN {
    use_ok('UFL::WebAdmin::SiteDeploy::Target::Rsync');
}

# Local target
{
    my $target = UFL::WebAdmin::SiteDeploy::Target::Rsync->new(
        path => '/var/www/dev.webadmin.ufl.edu/htdocs',
    );

    isa_ok($target, 'UFL::WebAdmin::SiteDeploy::Target::Rsync');
    isa_ok($target, 'UFL::WebAdmin::SiteDeploy::Target');

    is($target->name, 'test', 'default target name is test');
    is($target->username, undef, 'username is undef for local target');
    is($target->password, undef, 'password is undef for local target');
    is($target->hostname, undef, 'hostname is undef for local target');

    isa_ok($target->path, 'Path::Class::Dir');
    is($target->path, '/var/www/dev.webadmin.ufl.edu/htdocs', 'path is /var/www/dev.webadmin.ufl.edu/htdocs');

    ok(! $target->is_remote, 'local target is not remote');
    is($target->as_string, '/var/www/dev.webadmin.ufl.edu/htdocs', 'rsync target is correct');

    isa_ok($target->client, 'File::Rsync');
}

# Remote target
{
    my $target = UFL::WebAdmin::SiteDeploy::Target::Rsync->new(
        name     => 'prod',
        username => 'wwwuf',
        hostname => 'nersp.osg.ufl.edu',
        path => '/nerdc/www/www.ufl.edu',
        excludes => [ 'cgi-bin/*.txt', 'cgi-bin/*.db' ],
    );

    isa_ok($target, 'UFL::WebAdmin::SiteDeploy::Target::Rsync');
    isa_ok($target, 'UFL::WebAdmin::SiteDeploy::Target');

    is($target->name, 'prod', 'target name is prod');
    is($target->username, 'wwwuf', 'username is wwwuf');
    is($target->password, undef, 'password is empty');
    is($target->hostname, 'nersp.osg.ufl.edu', 'hostname is nersp.osg.ufl.edu');

    isa_ok($target->path, 'Path::Class::Dir');
    is($target->path, '/nerdc/www/www.ufl.edu', 'path is /nerdc/www/www.ufl.edu');

    is_deeply($target->excludes, [ 'cgi-bin/*.txt', 'cgi-bin/*.db' ], 'exclude list matches');

    ok($target->is_remote, 'target is remote');
    is($target->as_string, 'wwwuf@nersp.osg.ufl.edu:/nerdc/www/www.ufl.edu', 'rsync target is correct');

    isa_ok($target->client, 'File::Rsync');
}
