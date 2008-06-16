package UFL::WebAdmin::SiteDeploy::Site;

use Moose;
use UFL::WebAdmin::SiteDeploy::Types;

has 'uri' => (
    is => 'rw',
    isa => 'URI',
    required => 1,
    coerce => 1,
);

has 'repository' => (
    is => 'rw',
    isa => 'UFL::WebAdmin::SiteDeploy::Repository',
    required => 1,
);

=head1 NAME

UFL::WebAdmin::SiteDeploy::Site - A Web site

=head1 SYNOPSIS

    my $site = UFL::WebAdmin::SiteDeploy::Site->new(uri => 'http://www.ufl.edu/');

=head1 DESCRIPTION

This is a representation of a Web site managed by
L<UFL::WebAdmin::SiteDeploy>.

=head1 METHODS

=head2 identifier

Return the string that identifies this site in its associated
L<UFL::WebAdmin::SiteDeploy::Repository>.

=cut

sub identifier {
    return shift->uri->host;
}

=head2 prod_entries

Return the contents of the L<UFL::WebAdmin::SiteDeploy::Repository>
corresponding to commits to the production version of this site.

=cut

sub prod_entries {
    my ($self, $revision) = @_;

    return $self->repository->prod_entries($self, $revision);
}

=head2 deploy

Deploy this site from the repository.

=cut

sub deploy {
    my ($self, $revision, $message) = @_;

    $self->repository->deploy_site($self, $revision, $message);
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
