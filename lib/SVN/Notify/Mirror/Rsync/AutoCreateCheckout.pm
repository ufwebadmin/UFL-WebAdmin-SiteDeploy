package SVN::Notify::Mirror::Rsync::AutoCreateCheckout;

use strict;
use warnings;
use base qw/SVN::Notify::Mirror::Rsync Class::Accessor::Fast/;
use SVN::Client;
use UFL::WebAdmin::SiteDeploy;

__PACKAGE__->register_attributes(
    'repos_uri' => 'repos-uri:s',
);

__PACKAGE__->mk_accessors(qw/_svn_client/);

our $VERSION = $UFL::WebAdmin::SiteDeploy::VERSION;

=head1 NAME

SVN::Notify::Mirror::Rsync::AutoCreateCheckout - Automatically create the checkout directory

=head1 SYNOPSIS

    svnnotify --handler Mirror::Rsync::AutoCreateCheckout [...]

See also L<SVN::Notify::Mirror::Rsync>.

=head1 DESCRIPTION

This overrides L<SVN::Notify::Mirror::Rsync/_cd_run> to create the
local checkout directory if it doesn't already exist before doing
anything else.

=head1 METHODS

=head2 new

Create a new Subversion client for this instance.

=cut

sub new {
    my $self = shift->SUPER::new(@_);

    my $ctx = SVN::Client->new;
    $self->_svn_client($ctx);

    return $self;
}

=head2 _cd_run

Create the local checkout directory if it doesn't already exist and
then C<rsync> the checkout as normal.

=cut

sub _cd_run {
    my $self = shift;
    my $path = $_[0];

    die 'You must specify the repository URI' unless $self->repos_uri;

    if (-d $path) {
        # Check if we need to do a switch
        $self->_maybe_switch_checkout($path);
    }
    else {
        # Run the checkout
        $self->_checkout_repo($path);
    }

    $self->SUPER::_cd_run(@_);
}

=head2 _maybe_switch_checkout

Check the specified working copy against the configured repository
URL. If they don't match, switch the working copy to the configured
repository URL.

This is helpful, for example, when switching a site from trunk to a
branch.

NOTE: The case of tags is still not ideal due to the way that
L<SVN::Notify::Mirror/execute> handles switching. It is recommended
that the first tag be created and then any mirrored path be configured
with a C<repos_uri> of that tag.

=cut

sub _maybe_switch_checkout {
    my ($self, $path) = @_;

    my $uri;
    $self->_svn_client->info($path, undef, 'WORKING', sub { $uri = $_[1]->URL }, 0);

    if ($self->repos_uri ne $uri) {
        $self->_svn_client->switch($path, $self->repos_uri, $self->revision, 1);
    }
}

=head2 _checkout_repo

Checkout the configured repository to the specified path.

=cut

sub _checkout_repo {
    my ($self, $path) = @_;

    $self->_svn_client->checkout($self->repos_uri, $path, $self->revision, 1);
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
