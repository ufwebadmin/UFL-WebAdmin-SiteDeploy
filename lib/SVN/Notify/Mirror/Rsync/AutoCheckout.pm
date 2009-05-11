package SVN::Notify::Mirror::Rsync::AutoCheckout;

use Moose;
use Cwd ();

extends 'SVN::Notify::Mirror::Rsync';

__PACKAGE__->register_attributes(
    repos_uri    => 'repos-uri:s',
    tag_pattern  => 'tag-pattern:s',
    log_category => 'log-category:s',
);

override 'execute' => sub {
    my ($self) = @_;

    warn "Log category is not set" unless $self->log_category;

    my $cwd = Cwd::getcwd();
    super();
    chdir($cwd);
};

# XXX: Apply roles after overriding execute; otherwise Moose barfs
with 'UFL::WebAdmin::SiteDeploy::Role::CreateCheckout',
    'UFL::WebAdmin::SiteDeploy::Role::SwitchCheckout',
    'UFL::WebAdmin::SiteDeploy::Role::LogCommit';

=head1 NAME

SVN::Notify::Mirror::Rsync::AutoCheckout - Automatically create the checkout directory

=head1 SYNOPSIS

    svnnotify --handler Mirror::Rsync::AutoCheckout \
        --repos-uri "file:///var/svn/repos/websites/www.ufl.edu/trunk"
        [--tag-pattern "\d{12}"] \
        [--log-category "websites"]

See also L<SVN::Notify::Mirror::Rsync>.

=head1 DESCRIPTION

This overrides L<SVN::Notify::Mirror::Rsync/_cd_run> to create the
local checkout directory if it doesn't already exist before doing
anything else.

Additionally, it improves upon the tag handling of
L<SVN::Notify::Mirror>, which forces a specific repository structure
on the user.

=head1 METHODS

=head2 execute

Override L<SVN::Notify/execute> to set up default values for certain
attributes registered via L<SVN::Notify/register_attributes>.

=over 4

=item * C<log_category> - the value of C<__PACKAGE__>

=back

Additionally, override L<SVN::Notify::Mirror/execute> to return to the
previous working directory. Normally, L<SVN::Notify::Mirror/execute>
switches to the configured path.

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
