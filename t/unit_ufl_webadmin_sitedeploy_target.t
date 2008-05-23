#!perl

use strict;
use warnings;
use Test::More tests => 11;

BEGIN {
    use_ok('UFL::WebAdmin::SiteDeploy::Target');
}

{
    my $target = UFL::WebAdmin::SiteDeploy::Target->new(
        username => 'foo',
        password => 'bar',
        hostname => 'nersp.osg.ufl.edu',
    );

    isa_ok($target, 'UFL::WebAdmin::SiteDeploy::Target');

    is($target->name, 'test', 'default target name is test');
    is($target->username, 'foo', 'username is foo');
    is($target->password, 'bar', 'password is bar');
    is($target->hostname, 'nersp.osg.ufl.edu', 'hostname is nersp.osg.ufl.edu');
}

{
    my $target = UFL::WebAdmin::SiteDeploy::Target->new(
        name     => 'prod',
        username => 'wwwuf',
        password => 'blarg',
        hostname => 'nersp.osg.ufl.edu',
    );

    isa_ok($target, 'UFL::WebAdmin::SiteDeploy::Target');

    is($target->name, 'prod', 'target name is prod');
    is($target->username, 'wwwuf', 'username is wwwuf');
    is($target->password, 'blarg', 'password is blarg');
    is($target->hostname, 'nersp.osg.ufl.edu', 'hostname is nersp.osg.ufl.edu');
}
