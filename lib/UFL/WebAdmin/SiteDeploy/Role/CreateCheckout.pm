package UFL::WebAdmin::SiteDeploy::Role::CreateCheckout;

use Moose::Role;
use SVN::Client;

requires 'repos_uri';
requires 'revision';

has '_svn_client' => (
    is => 'rw',
    isa => 'SVN::Client',
    default => sub { SVN::Client->new },
    lazy => 1,
);

before '_cd_run' => sub {
    my ($self, $path) = @_;

    $self->create_checkout($path);
};

=head1 NAME

UFL::WebAdmin::SiteDeploy::Role::CreateCheckout - Create an existing checkout

=head1 SYNOPSIS

    package SVN::Notify::Mirror::Smarter;
    use Moose;
    with 'UFL::WebAdmin::SiteDeploy::Role::CreateCheckout';

=head1 DESCRIPTION

This overrides L<SVN::Notify::Mirror/_cd_run> to create the local
checkout directory if it doesn't already exist before doing anything
else.

=head1 METHODS

=head2 create_checkout

Checkout the configured repository to the specified path.

=cut

sub create_checkout {
    my ($self, $path) = @_;

    return if -d $path;

    $self->_svn_client->checkout($self->repos_uri, $path, $self->revision, 1);
}

=head1 SEE ALSO

=over 4

=item * L<SVN::Notify::Mirror::Rsync::AutoCheckout>.

=back

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
