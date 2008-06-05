use inc::Module::Install;

name     'UFL-WebAdmin-SiteDeploy';
all_from 'lib/UFL/WebAdmin/SiteDeploy.pm';

requires 'Cwd';
requires 'IO::String';
requires 'Log::Log4perl';
requires 'Moose';
requires 'Moose::Role';
requires 'Moose::Util::TypeConstraints';
requires 'MooseX::App::Cmd';
requires 'MooseX::App::Cmd::Command';
requires 'MooseX::Getopt';
requires 'Path::Class::Dir';
requires 'SVN::Client';
requires 'SVN::Notify';
requires 'SVN::Notify::Config';
requires 'SVN::Notify::Mirror::Rsync';
requires 'UFL::WebAdmin::SVN';
requires 'URI';
requires 'URI::file';
requires 'YAML';

# For script/*.sh
requires_external_bin '/usr/bin/env';
requires_external_bin 'perl';

# All for SVN::Notify::Mirror::Rsync::AutoCheckout
requires_external_bin 'rsync';
requires_external_bin 'ssh';
requires_external_bin 'svn';
requires_external_bin 'svnlook';

build_requires 'File::Path';
build_requires 'File::Spec';
build_requires 'FindBin';
build_requires 'Test::Log4perl';
build_requires 'Test::More';

install_script glob('script/*.pl');

WriteAll;
