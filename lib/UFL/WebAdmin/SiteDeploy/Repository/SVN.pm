package UFL::WebAdmin::SiteDeploy::Repository::SVN;

use Moose;
use SVN::Client;

extends 'UFL::WebAdmin::SiteDeploy::Repository';

has '+client' => (
    isa => 'SVN::Client',
    default => sub { SVN::Client->new },
);

=head1 NAME

UFL::WebAdmin::SiteDeploy::Repository::SVN - An Subversion repository

=head1 SYNOPSIS

    my $site = UFL::WebAdmin::SiteDeploy::Repository::SVN->new(uri => 'file:///var/svn/repos/websites');
    my $site = UFL::WebAdmin::SiteDeploy::Repository::SVN->new(uri => 'https://svn.webadmin.ufl.edu/repos/websites/');

=head1 DESCRIPTION

This is an implementation of a repository containing one or more Web
sites, using Subversion as the revision control system.

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
