package UFL::WebAdmin::SiteDeploy::Site;

use Moose;
use UFL::WebAdmin::SiteDeploy::Types;

has 'uri' => (
    is => 'rw',
    isa => 'URI',
    coerce => 1,
);

=head1 NAME

UFL::WebAdmin::SiteDeploy::Site - A Web site

=head1 SYNOPSIS

    my $site = UFL::WebAdmin::SiteDeploy::Site->new(uri => 'http://www.ufl.edu/');

=head1 DESCRIPTION

This is a representation of a Web site managed by
L<UFL::WebAdmin::SiteDeploy>.

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
