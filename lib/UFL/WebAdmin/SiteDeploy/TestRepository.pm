package UFL::WebAdmin::SiteDeploy::TestRepository;

use Moose;
use FindBin;
use Path::Class::Dir;
use Path::Class::File;
use UFL::WebAdmin::SiteDeploy::Types;
use URI::file;

has 'base' => (
    is => 'rw',
    isa => 'Path::Class::Dir',
    coerce => 1,
    required => 1,
    default => sub { Path::Class::Dir->new($FindBin::Bin) },
);

has 'dump_file' => (
    is => 'rw',
    isa => 'Path::Class::File',
    coerce => 1,
    required => 1,
    default => sub { Path::Class::File->new($FindBin::Bin, 'data', 'repo.dump') },
);

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

=head1 METHODS

=head2 scratch_dir

Return the L<Path::Class::Dir> to our scratch space.

=cut

sub scratch_dir {
    return shift->base->subdir('var');
}

=head2 repository_dir

Return the L<Path::Class::Dir> to our scratch repository directory.

=cut

sub repository_dir {
    return shift->scratch_dir->subdir('repository');
}

=head2 repository_uri

Return the L<URI> to our scratch repository directory.

=cut

sub repository_uri {
    my ($self) = @_;

    my $uri = URI::file->new($self->repository_dir);

    return $uri;
}

=head2 checkout_dir

Return the L<Path::Class::Dir> to our scratch checkout directory.

=cut

sub checkout_dir {
    return shift->scratch_dir->subdir('checkout');
}

=head2 init

Run cleanup tasks and then reload the repository from our configured
dump file.

=cut

sub init {
    my ($self) = @_;

    $self->cleanup;
    $self->load_repository;
}

=head2 cleanup

Remove any scratch content.

=cut

sub cleanup {
    my ($self) = @_;

    $self->scratch_dir->rmtree if -d $self->scratch_dir;
}

=head2 load_repository

Load the repository from our configured dump file.

=cut

sub load_repository {
    my ($self) = @_;

    $self->scratch_dir->mkpath;

    my $repository_dir = $self->repository_dir;
    my $dump_file = $self->dump_file;

    system('svnadmin', 'create', $repository_dir);
    qx{svnadmin load "$repository_dir" < "$dump_file"};
}

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
