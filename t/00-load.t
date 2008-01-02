#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'UFL::WebAdmin::SiteDeploy' );
}

diag( "Testing UFL::WebAdmin::SiteDeploy $UFL::WebAdmin::SiteDeploy::VERSION, Perl $], $^X" );
