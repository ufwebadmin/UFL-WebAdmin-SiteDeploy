package UFL::WebAdmin::SiteDeploy::Repository::SVN;

use Moose;
use DateTime;
use SVN::Client;

extends 'UFL::WebAdmin::SiteDeploy::Repository';

has '+client' => (
    isa => 'SVN::Client',
    default => sub { SVN::Client->new },
);

=head1 NAME

UFL::WebAdmin::SiteDeploy::Repository::SVN - An Subversion repository

=head1 SYNOPSIS

    my $repo = UFL::WebAdmin::SiteDeploy::Repository::SVN->new(uri => 'file:///var/svn/repos/websites');
    my $repo = UFL::WebAdmin::SiteDeploy::Repository::SVN->new(uri => 'https://svn.webadmin.ufl.edu/repos/websites/');

=head1 DESCRIPTION

This is an implementation of a repository containing one or more Web
sites, using Subversion as the revision control system.

=head1 METHODS

=head2 entries

Return the contents of the repository as of the specified revision.

    my $entries = $repo->entries;
    print $entries->{www.ufl.edu}->created_rev;

    my $entries = $repo->entries([ 'www.ufl.edu', 'tags' ], 100);
    print $entries->{200806161150}->created_rev;

=cut

sub entries {
    my ($self, $path_segments, $revision) = @_;

    my $uri = $self->uri->clone;
    $uri->path_segments($uri->path_segments, @$path_segments);

    $revision = defined $revision ? $revision : 'HEAD';

    my $entries = $self->client->ls($uri, $revision, 0);

    return $entries;
}

=head2 test_entries

Return the contents of the repository for the specified
L<UFL::WebAdmin::SiteDeploy::Site> corresponding to actions in test.

=cut

sub test_entries {
    my ($self, $site, $revision) = @_;

    return $self->entries([ $site->uri->host, 'trunk' ], $revision);
}

=head2 prod_entries

Return the contents of the repository for the specified
L<UFL::WebAdmin::SiteDeploy::Site> corresponding to actions in
production.

=cut

sub prod_entries {
    my ($self, $site, $revision) = @_;

    return $self->entries([ $site->uri->host, 'tags' ], $revision);
}

=head2 deploy_site

Deploy the specified Web site from the repository. In Subversion
repositories, this operation involves copying the C<trunk> directory
to a location in the C<tags> directory named based on the current date
and time. For example:

    svn copy trunk/ tags/200806101037/
    svn ci -m "Deploying to production"

=cut

sub deploy_site {
    my ($self, $site, $revision, $message) = @_;

    my $src = $self->_source_uri($site);
    my $dst = $self->_destination_uri($site);

    $self->client->log_msg(sub {
        my ($msg) = @_;
        $$msg = $message;
    });

    $self->client->copy($src, $revision, $dst);

    $self->client->log_msg(undef);
}

=head2 _site_uri

Return a L<URI> relative to the repository URI.

=cut

sub _site_uri {
    my ($self, @path_segments) = @_;

    my $uri = $self->uri->clone;
    $uri->path_segments($uri->path_segments, @path_segments);

    # Collapse multiple slashes
    my $path = $uri->path;
    $path =~ s|/{2,}|/|g;
    $uri->path($path);

    return $uri;
}

=head2 _source_uri

Return a L<URI> to the location of the site in the repository that
will be used as the source of the tagging operation.

=cut

sub _source_uri {
    my ($self, $site) = @_;

    my $uri = $self->_site_uri($site->uri->host, 'trunk');

    return $uri;
}

=head2 _destination_uri

Return a L<URI> to the location of the site in the repository that
will be used as the destination of the tagging operation.

=cut

sub _destination_uri {
    my ($self, $site) = @_;

    my $dt = DateTime->now(time_zone => 'local');
    my $stamp = $dt->ymd('') . $dt->strftime('%H%M');

    my $uri = $self->_site_uri($site->uri->host, 'tags', $stamp);

    return $uri;
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
