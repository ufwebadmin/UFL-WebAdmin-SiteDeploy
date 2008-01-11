use inc::Module::Install;

name     'UFL-WebAdmin-SiteDeploy';
all_from 'lib/UFL/WebAdmin/SiteDeploy.pm';

build_requires 'Test::More';

install_script glob('script/*.pl'), glob('script/*.sh');

WriteAll;
