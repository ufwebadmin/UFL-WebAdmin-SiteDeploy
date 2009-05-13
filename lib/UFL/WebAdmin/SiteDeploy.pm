package UFL::WebAdmin::SiteDeploy;

use Moose;

extends 'MooseX::App::Cmd';

our $VERSION = '0.12';

=head1 NAME

UFL::WebAdmin::SiteDeploy - Automatic Web site deployment

=head1 SYNOPSIS

    svn checkout https://svn.webadmin.ufl.edu/websites/www.ufl.edu/trunk/ www.ufl.edu
    emacs index.html
    svn commit -m "Some cool change"

    ufl_webadmin_sitedeploy.pl deploy --path /var/svn/websites --revision 100

=head1 DESCRIPTION

This is a set of scripts designed to ease deployment of static Web
sites managed by Web Administration at the University of Florida.

Based on a small amount of configuration, content is deployed via
C<rsync(1)> to one or more sites. For example, when a change is
committed to the C<www.ufl.edu> repository, that change is
automatically sent to L<http://test.www.ufl.edu/>.

This saves each committer time and effort in figuring out what files
need to be uploaded.

=head1 SEE ALSO

=over 4

=item * L<UFL::WebAdmin::SiteDeploy::Command::deploy>

=back

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
