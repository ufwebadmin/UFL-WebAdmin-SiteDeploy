package SVN::Notify::Mirror::Rsync::AutoCreateCheckout;

use strict;
use warnings;
use base qw/SVN::Notify::Mirror::Rsync/;

__PACKAGE__->register_attributes(
    'repos_uri' => 'repos-uri:s',
);

our $VERSION = '0.01';

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

=head2 _cd_run

Create the local checkout directory if it doesn't already exist and
then C<rsync> the checkout as normal.

=cut

sub _cd_run {
    my $self = shift;
    my $path = $_[0];

    die 'You must specify the repository URI' unless $self->repos_uri;

    unless (-d $path) {
        system($self->svn_binary, 'checkout', $self->repos_uri, $path);
    }

    $self->SUPER::_cd_run(@_);
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
