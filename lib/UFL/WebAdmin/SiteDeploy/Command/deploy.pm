package UFL::WebAdmin::SiteDeploy::Command::deploy;

use Moose;
use IO::String;
use SVN::Client;
use URI::file;
use YAML;

extends 'MooseX::App::Cmd::Command';

# XXX: Would like path and log_config to be Path::Class::Dirs but
# XXX: coercion fails on MooseX::Getopt 0.11 and MooseX::App::Cmd 0.02

has 'path' => (
    metaclass => 'MooseX::Getopt::Meta::Attribute',
    is => 'rw',
    isa => 'Str',
    required => 1,
    cmd_aliases => 'p',
    documentation => 'the path to the repository',
);

has 'revision' => (
    metaclass => 'MooseX::Getopt::Meta::Attribute',
    is => 'rw',
    isa => 'Int',
    required => 1,
    cmd_aliases => 'r',
    documentation => 'the revision to deploy',
);

has 'svn_notify_config' => (
    metaclass => 'MooseX::Getopt::Meta::Attribute',
    is => 'rw',
    isa => 'Str',
    default => 'svnnotify.yml',
    cmd_aliases => 's',
    documentation => 'the name of the configuration file in the repository (defaults to svnnotify.yml)',
);

has 'log_config' => (
    metaclass => 'MooseX::Getopt::Meta::Attribute',
    is => 'rw',
    isa => 'Str',
    cmd_aliases => 'l',
    documentation => 'the path to a Log::Log4perl configuration file',
);

=head1 NAME

UFL::WebAdmin::SiteDeploy::Command::deploy - deploy a Web site

=head1 SYNOPSIS

    ufl_webadmin_sitedeploy.pl deploy --path /var/svn/websites --revision 100

=head1 METHODS

=head2 run

Deploy the specified revision in the specific repository using
L<SVN::Notify::Config>.

=cut

sub run {
    my ($self, $opt, $args) = @_;

    if ($self->log_config) {
        require Log::Log4perl;
        Log::Log4perl->init($self->log_config);
    }

    my $svn_notify_config = $self->_load_svn_notify_config;

    # Normally this work is done in SVN::Notify::Config->import, but
    # that method is a giant hack
    require SVN::Notify::Config;
    my $handler = SVN::Notify::Config->new($svn_notify_config);
    $handler->prepare;
    $handler->execute(
        repos_path => $self->path,
        revision   => $self->revision,
    );
}

sub _repository_uri {
    my ($self) = @_;

    my $uri = URI::file->new($self->path);

    return $uri;
}

sub _svn_notify_config_uri {
    my ($self) = @_;

    my $uri = $self->_repository_uri;
    $uri->path_segments($uri->path_segments, $self->svn_notify_config);

    return $uri;
}

sub _load_svn_notify_config {
    my ($self) = @_;

    my $config;
    my $fh = IO::String->new($config);

    my $uri = $self->_svn_notify_config_uri;

    my $client = SVN::Client->new;
    $client->cat($fh, $uri->as_string, $self->revision);

    return YAML::Load($config);
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
