use inc::Module::Install;

name     'UFL-WebAdmin-SiteDeploy';
all_from 'lib/UFL/WebAdmin/SiteDeploy.pm';

requires 'SVN::Notify';

# All for SVN::Notify::Mirror::Rsync::AutoCreateCheckout
requires_external_bin 'svn';
requires_external_bin 'svnlook';
requires_external_bin 'ssh';

build_requires 'Test::More';

install_script glob('script/*.pl'), glob('script/*.sh');

WriteAll;
