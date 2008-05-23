package UFL::WebAdmin::SiteDeploy::Target::Rsync;

use Moose;
use File::Rsync;
use UFL::WebAdmin::SiteDeploy::Types;

extends 'UFL::WebAdmin::SiteDeploy::Target';

has 'path' => (
    is => 'rw',
    isa => 'Path::Class::Dir',
    required => 1,
    coerce => 1,
);

has 'excludes' => (
    is => 'rw',
    isa => 'ArrayRef[Str]',
    default => sub { [] },
);

has 'client' => (
    is => 'rw',
    isa => 'File::Rsync',
    default => sub {
        File::Rsync->new({
            rsh => 'ssh',
            archive => 1,
            compress => 1,
            'delete-after' => 1,
        })
    },
);

=head1 NAME

UFL::WebAdmin::SiteDeploy::Target::Rsync - A Web site deployment location, over rsync(1)

=head1 SYNOPSIS

    my $target = UFL::WebAdmin::SiteDeploy::Target::Rsync->new(
        name => 'prod',
        username => 'wwwuf',
        hostname => 'nersp.osg.ufl.edu',
        path => '/nerdc/www/www.ufl.edu',
    );

=head1 DESCRIPTION

An C<rsync(1)> target for deploying a Web site.

=head1 METHODS

=head2 is_remote

Return true iff this target is remote (i.e. it has a host part).

=cut

sub is_remote {
    my ($self) = @_;

    return $self->hostname ? 1 : 0;
}

=head2 as_string

Return a string appropriate for use as an C<rsync(1)> or
L<File::Rsync> destination.

=cut

sub as_string {
    my ($self) = @_;

    my $target = $self->path;
    if ($self->is_remote) {
        if (my $username = $self->username) {
            $target = $username . '@';
        }

        $target .= $self->hostname . ':' . $self->path;
    }

    return $target;
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
