use inc::Module::Install;

name     'UFL-WebAdmin-SiteDeploy';
all_from 'lib/UFL/WebAdmin/SiteDeploy.pm';
author   'Daniel Westermann-Clark <dwc@ufl.edu>';

build_requires 'Test::More';

auto_install;

WriteAll;

