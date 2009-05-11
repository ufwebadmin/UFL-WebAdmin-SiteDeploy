use inc::Module::Install;

name     'UFL-WebAdmin-SiteDeploy';
all_from 'lib/UFL/WebAdmin/SiteDeploy.pm';

requires 'Cwd';
requires 'DateTime';
requires 'IO::String';
requires 'Log::Log4perl';
requires 'Moose';
requires 'Moose::Role';
requires 'Moose::Util::TypeConstraints';
requires 'MooseX::App::Cmd';
requires 'MooseX::App::Cmd::Command';
requires 'MooseX::Getopt';
requires 'Net::SSH';
requires 'Path::Abstract';
requires 'Path::Class::Dir';
requires 'Path::Class::File';
requires 'SVN::Client';
requires 'SVN::Notify::Config';
requires 'SVN::Notify::Mirror::Rsync';
requires 'UFL::WebAdmin::SVN';
requires 'URI';
requires 'URI::file';
requires 'VCI::Abstract::Project';
requires 'YAML';

# For script/*.pl
requires_external_bin '/usr/bin/env';
requires_external_bin 'perl';

# For SVN::Notify::Mirror::Rsync::AutoCheckout
requires_external_bin 'rsync';
requires_external_bin 'ssh';
requires_external_bin 'svn';
requires_external_bin 'svnlook';

# For tests
requires_external_bin 'hostname';
requires_external_bin 'svnadmin';

build_requires 'FindBin';
build_requires 'Moose';
build_requires 'Path::Class::Dir';
build_requires 'Path::Class::File';
build_requires 'Log::Log4perl';
build_requires 'Test::Log4perl';
build_requires 'Test::More';
build_requires 'URI::file';
build_requires 'VCI';

install_script glob('script/*.pl');

clean_files('t/var');

WriteAll;
