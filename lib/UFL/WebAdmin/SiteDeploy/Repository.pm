package UFL::WebAdmin::SiteDeploy::Repository;

use Moose;
use UFL::WebAdmin::SiteDeploy::Types;

has 'uri' => (
    is => 'rw',
    isa => 'URI',
    coerce => 1,
);

has 'client' => (
    is => 'rw',
    isa => 'Object',
);

=head1 NAME

UFL::WebAdmin::SiteDeploy::Repository - An abstract revision control repository

=head1 SYNOPSIS

    my $site = UFL::WebAdmin::SiteDeploy::Repository::SVN->new(uri => 'file:///var/svn/repos/websites');
    my $site = UFL::WebAdmin::SiteDeploy::Repository::SVN->new(uri => 'https://svn.webadmin.ufl.edu/repos/websites/');

=head1 DESCRIPTION

This is an abstract representation of a revision control repository.
Typically, you will want to use an actual implementation, such as
L<UFL::WebAdmin::SiteDeploy::Repository::SVN>.

Repositories contain one ore more Web sites, located at the base of
the repository. For example:

    /
        www.ufl.edu/
        www.webadmin.ufl.edu/

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
