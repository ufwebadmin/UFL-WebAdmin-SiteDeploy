use inc::Module::Install;

name     'UFL-WebAdmin-SiteDeploy';
all_from 'lib/UFL/WebAdmin/SiteDeploy.pm';

requires 'Class::Accessor::Fast';
requires 'File::Rsync';
requires 'Moose';
requires 'Moose::Util::TypeConstraints';
requires 'Path::Class::Dir';
requires 'SVN::Client';
requires 'SVN::Notify';
requires 'SVN::Notify::Config';
requires 'SVN::Notify::Mirror::Rsync';
requires 'URI';

# For script/*.sh
requires_external_bin '/bin/sh';
requires_external_bin '/usr/bin/perl';
requires_external_bin '/usr/bin/svnlook';
requires_external_bin '/usr/bin/svnnotify';
requires_external_bin '/usr/local/bin/trac-post-commit';

# All for SVN::Notify::Mirror::Rsync::AutoCreateCheckout
requires_external_bin 'rsync';
requires_external_bin 'ssh';
requires_external_bin 'svn';
requires_external_bin 'svnlook';

build_requires 'Cwd';
build_requires 'File::Path';
build_requires 'File::Spec';
build_requires 'FindBin';
build_requires 'Test::More';

install_script glob('script/*.pl'), glob('script/*.sh');

WriteAll;
