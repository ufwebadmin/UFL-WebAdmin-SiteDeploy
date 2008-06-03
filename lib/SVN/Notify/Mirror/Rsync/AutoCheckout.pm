package SVN::Notify::Mirror::Rsync::AutoCheckout;

use Moose;
use UFL::WebAdmin::SiteDeploy;

extends 'SVN::Notify::Mirror::Rsync';

__PACKAGE__->register_attributes(
    repos_uri    => 'repos-uri:s',
    tag_pattern  => 'tag-pattern:s',
    log_category => 'log-category:s',
);

with 'UFL::WebAdmin::SiteDeploy::Role::CreateCheckout';
with 'UFL::WebAdmin::SiteDeploy::Role::SwitchCheckout';
with 'UFL::WebAdmin::SiteDeploy::Role::CommitLogger';

our $VERSION = $UFL::WebAdmin::SiteDeploy::VERSION;

=head1 NAME

SVN::Notify::Mirror::Rsync::AutoCheckout - Automatically create the checkout directory

=head1 SYNOPSIS

    svnnotify --handler Mirror::Rsync::AutoCheckout \
        --repos-uri "file:///var/svn/repos/websites/www.ufl.edu/trunk"
        [--tag-pattern "\d{12}"] \
        [--log-category "UFL.WebAdmin.SVN.WebSites"]

See also L<SVN::Notify::Mirror::Rsync>.

=head1 DESCRIPTION

This overrides L<SVN::Notify::Mirror::Rsync/_cd_run> to create the
local checkout directory if it doesn't already exist before doing
anything else.

Additionally, it improves upon the tag handling of
L<SVN::Notify::Mirror>, which forces a specific repository structure
on the user.

=head1 METHODS

=head2 new

Override L<SVN::Notify/new> to set up any default values for
attributes registered via L<SVN::Notify/register_attributes>. (This is
done using standard inheritance due because L<Moose> is not injected
into the code above this class.)

=cut

sub new {
    my $self = shift->SUPER::new(@_);

    $self->log_category(__PACKAGE__) unless $self->log_category;

    return $self;
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
