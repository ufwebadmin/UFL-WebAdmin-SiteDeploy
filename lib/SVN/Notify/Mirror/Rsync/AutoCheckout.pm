package SVN::Notify::Mirror::Rsync::AutoCheckout;

use Moose;
use Cwd ();

extends 'SVN::Notify::Mirror::Rsync';

with 'UFL::WebAdmin::SiteDeploy::Role::CreateCheckout',
    'UFL::WebAdmin::SiteDeploy::Role::SwitchCheckout',
    'UFL::WebAdmin::SiteDeploy::Role::LogCommit';

# Register arguments for SVN::Notify
__PACKAGE__->register_attributes(
    repos_uri    => 'repos-uri:s',
    tag_pattern  => 'tag-pattern:s',
    chown_spec   => 'chown-spec:s',
    log_category => 'log-category:s',
);

around 'execute' => sub {
    my $next = shift;
    my $self = $_[0];

    warn "Log category is not set" unless $self->log_category;

    # SVN::Notify::Mirror switches to the configured path, so put us
    # back where we started
    my $cwd = Cwd::getcwd();
    $next->(@_);
    chdir($cwd);
};

# XXX: Should this be a role?
after 'execute' => sub {
    my ($self) = @_;

    my $chown_spec = $self->chown_spec;
    return unless $self->rsync_ssh and $chown_spec;

    # Update the ownership for suEXEC
    my $rsync_dest = $self->rsync_dest;
    $self->_log->debug("Changing ownership of files under [$rsync_dest] to [$chown_spec]");

    my ($stdout, $stderr);
    eval {
        require Net::SSH;

        $stdout = Net::SSH::ssh_cmd({
            user => $self->ssh_user,
            host => $self->rsync_host,
            command => 'chown',
            args => [ '-R', $chown_spec, $rsync_dest ],
        });
    };
    if ($@) {
        $stderr = $@;
    }

    $self->_log_multiline("Output", split /\n/, $stdout)
        if $stdout;
    $self->_log_multiline("Error", split /\n/, $stderr)
        if $stderr;
    
    $self->_log->debug("Finished changing ownership");
};

=head1 NAME

SVN::Notify::Mirror::Rsync::AutoCheckout - Automatically create the checkout directory

=head1 SYNOPSIS

    svnnotify --handler Mirror::Rsync::AutoCheckout \
        --repos-uri "file:///var/svn/repos/websites/www.ufl.edu/trunk"
        [--tag-pattern "\d{12}"] \
        [--chown-spec "wwwuf:webuf"] \
        [--log-category "websites"]

See also L<SVN::Notify::Mirror::Rsync>.

=head1 DESCRIPTION

This overrides L<SVN::Notify::Mirror::Rsync/_cd_run> to create the
local checkout directory if it doesn't already exist before doing
anything else.

Additionally, it improves upon the tag handling of
L<SVN::Notify::Mirror>, which forces a specific repository structure
on the user.

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
