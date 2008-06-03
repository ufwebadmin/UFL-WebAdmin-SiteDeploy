package UFL::WebAdmin::SiteDeploy::Role::SwitchCheckout;

use Moose::Role;
use SVN::Client;

requires 'repos_uri';
requires 'revision';

before '_cd_run' => sub {
    my ($self, $path) = @_;

    $self->maybe_switch_checkout($path);
};

=head1 NAME

UFL::WebAdmin::SiteDeploy::Role::SwitchCheckout - Switch an existing checkout

=head1 SYNOPSIS

    package SVN::Notify::Mirror::Smarter;
    use Moose;
    with 'UFL::WebAdmin::SiteDeploy::Role::SwitchCheckout';

=head1 DESCRIPTION

This overrides L<SVN::Notify::Mirror/_cd_run> to switch an existing
checkout to a new tag or branch. It improves upon the tag handling of
L<SVN::Notify::Mirror>, which forces a specific repository structure
on the user.

=head1 METHODS

=head2 maybe_switch_checkout

Check the specified working copy against the configured repository
URL. If they don't match, switch the working copy to the configured
repository URL.

This is helpful, for example, when switching a site from trunk to a
branch.

Additionally - if a tag pattern is configured, the working copy URL
matches the tag pattern, and a new tag is created matching the pattern
- switch the working copy to the new tag. This overrides the switching
behavior of L<SVN::Notify::Mirror/execute>, which assumes too much
about the structure of the repository.

=cut

sub maybe_switch_checkout {
    my ($self, $path) = @_;

    return unless -d $path;

    my $client = SVN::Client->new;

    my $uri;
    $client->info($path, undef, 'WORKING', sub { $uri = $_[1]->URL }, 0);

    if (my $tag_pattern = $self->tag_pattern and my @added_files = @{ $self->{files}{A} || [] }) {
        # Check for a new tag
        if ($uri =~ /($tag_pattern)/) {
            my $old_tag = $1;

            # We only care about the first entry, the added tag directory
            my $tag_dir = $added_files[0];
            if ($tag_dir =~ /($tag_pattern)/) {
                my $new_tag = $1;
                $uri =~ s/$old_tag/$new_tag/;

                $client->switch($path, $uri, $self->revision, 1);
            }
        }
    }
    elsif ($self->repos_uri ne $uri) {
        # Assume we've been configured to switch to e.g. a branch
        $client->switch($path, $self->repos_uri, $self->revision, 1);
    }
}

=head1 SEE ALSO

=over 4

=item * L<SVN::Notify::Mirror::Rsync::AutoCheckout>

=back

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
