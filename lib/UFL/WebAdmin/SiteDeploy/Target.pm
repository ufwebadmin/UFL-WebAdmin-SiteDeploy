package UFL::WebAdmin::SiteDeploy::Target;

use Moose;

has 'name' => (
    is => 'rw',
    isa => 'Str',
    default => 'test',
);

has 'username' => (
    is => 'rw',
    isa => 'Str',
);

has 'password' => (
    is => 'rw',
    isa => 'Str',
);

has 'hostname' => (
    is => 'rw',
    isa => 'Str',
);

=head1 NAME

UFL::WebAdmin::SiteDeploy::Target - A Web site deployment location

=head1 SYNOPSIS

    my $target = UFL::WebAdmin::SiteDeploy::Target::Rsync->new(
        name => 'prod',
        username => 'wwwuf',
        hostname => 'nersp.osg.ufl.edu',
        path => '/nerdc/www/www.ufl.edu',
    );

=head1 DESCRIPTION

This is an abstract represenation of a deployment location for a Web
site. Typically, you will want to use an actual implementation, such
as L<UFL::WebAdmin::SiteDeploy::Target::Rsync>.

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
