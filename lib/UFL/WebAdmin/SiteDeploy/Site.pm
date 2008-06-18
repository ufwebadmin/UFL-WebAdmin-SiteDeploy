package UFL::WebAdmin::SiteDeploy::Site;

use Moose;
use DateTime;
use Path::Abstract;
use SVN::Client;
use UFL::WebAdmin::SiteDeploy::Types;

has 'project' => (
    is => 'rw',
    isa => 'VCI::Abstract::Project',
    required => 1,
);

has 'scheme' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
    default => sub { 'http' },
);

has 'path' => (
    is => 'rw',
    isa => 'Path::Abstract',
    coerce => 1,
    required => 1,
    default => sub { Path::Abstract->new('/') },
);

has 'test_path' => (
    is => 'rw',
    isa => 'Path::Abstract',
    coerce => 1,
    required => 1,
    default => sub { Path::Abstract->new('trunk') },
);

has 'prod_path' => (
    is => 'rw',
    isa => 'Path::Abstract',
    coerce => 1,
    required => 1,
    default => sub { Path::Abstract->new('tags') },
);

=head1 NAME

UFL::WebAdmin::SiteDeploy::Site - A Web site

=head1 SYNOPSIS

    my $repository = VCI->connect(...);
    my $project = $repository->get_project(name => 'www.ufl.edu');
    my $site = UFL::WebAdmin::SiteDeploy::Site->new(project => $project);

=head1 DESCRIPTION

This is a representation of a Web site managed by
L<UFL::WebAdmin::SiteDeploy>.

=head1 METHODS

=head2 id

Return an identifier for this site, which is the same as the
L<VCI::Abstract::Project> name.

=cut

sub id {
    return shift->project->name;
}

=head2 uri

Return the L<URI> for this site.

=cut

sub uri {
    my ($self) = @_;

    my $uri = URI->new;
    $uri->scheme($self->scheme);
    $uri->host($self->id);
    $uri->path($self->path);

    return $uri;
}

=head2 update_history

Return the L<VCI::Abstract::History> object corresponding with
updating the test version of this site.

=cut

sub update_history {
    return shift->_test_directory->contents_history_recursive;
}

=head2 update_commits

Return the L<VCI::Abstract::Commit> objects corresponding with
updating the test version of this site.

=cut

sub update_commits {
    return shift->update_history->commits;
}

=head2 last_update

Return the L<VCI::Abstract::Commit> corresponding to the last time
this site was updated (in test).

=cut

sub last_update {
    my ($self) = @_;

    my $last_revision = $self->_test_directory->revision;
    my $commit = $self->project->get_commit(revision => $last_revision);

    return $commit;
}

=head2 _test_directory

Return the L<VCI::Abstract::Directory> which contains the work done to
this site in test.

=cut

sub _test_directory {
    my ($self) = @_;

    return $self->project->get_directory(path => $self->test_path);
}

=head2 deployments

Return the L<VCI::Abstract::Committable> objects corresponding with
deploying to the production version of this site.

=cut

sub deployments {
    return shift->_prod_directory->contents;
}

=head2 deploy_history

Return the L<VCI::Abstract::History> object corresponding with
deploying to the production version of this site.

=cut

sub deploy_history {
    return shift->_prod_directory->contents_history;
}

=head2 deploy_commits

Return the L<VCI::Abstract::Commit> objects corresponding to deploying
to the production version of this site.

=cut

sub deploy_commits {
    return shift->deploy_history->commits;
}

=head2 last_deployment

Return the L<VCI::Abstract::Commit> corresponding to the last time
this site was deployed to production.

=cut

sub last_deployment {
    my ($self) = @_;

    my $last_revision = $self->_prod_directory->revision;
    my $commit = $self->project->get_commit(revision => $last_revision);

    return $commit;
}

=head2 _prod_directory

Return the L<VCI::Abstract::Directory> which contains the actual work
done to deploy this site to production.

=cut

sub _prod_directory {
    my ($self) = @_;

    return $self->project->get_directory(path => $self->prod_path);
}

=head2 deploy

Deploy this site to production from the repository.

=cut

sub deploy {
    my ($self, $revision, $message) = @_;

    # TODO: Abstract using VCI
    my $src = $self->_source_uri($self);
    my $dst = $self->_destination_uri($self);

    my $client = SVN::Client->new;

    eval {
        $client->ls($dst, 'HEAD', 0);
    };
    unless ($@) {
        die "Site has already been deployed to $dst"
    }

    $client->log_msg(sub {
        my ($msg) = @_;
        $$msg = $message;
    });

    $client->copy($src, $revision, $dst);

    $self->_reload_project;
}

=head2 _source_uri

Return a L<URI> to the location of the site in the repository that
will be used as the source of the tagging operation.

=cut

sub _source_uri {
    my ($self) = @_;

    return $self->_repository_uri($self->test_path);
}

=head2 _destination_uri

Return a L<URI> to the location of the site in the repository that
will be used as the destination of the tagging operation.

=cut

sub _destination_uri {
    my ($self, $site) = @_;

    my $dt = DateTime->now(time_zone => 'local');
    my $stamp = $dt->ymd('') . $dt->strftime('%H%M');

    my $path = $self->prod_path->child($stamp);

    return $self->_repository_uri($path);
}

=head2 _repository_uri

Return a L<URI> to the repository corresponding to the specified path.

=cut

sub _repository_uri {
    my ($self, $subpath) = @_;

    my $root = URI->new($self->project->repository->root);
    my $path = Path::Abstract->new($self->id, $subpath);

    my $uri = URI->new_abs($path, $root);

    return $uri;
}

=head2 _reload_project

Reload the L<VCI::Abstract::Project> from the associated
repository. This is useful, for example, after a L</deploy> operation
to load any new history about the project.

=cut

sub _reload_project {
    my ($self) = @_;

    my $repository = $self->project->repository;
    my $project = $repository->get_project(name => $self->id);

    $self->project($project);
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
