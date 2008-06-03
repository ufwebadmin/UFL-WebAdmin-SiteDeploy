package UFL::WebAdmin::SiteDeploy::Role::CommitLogger;

use Moose::Role;
use Log::Log4perl;

requires 'log_category';

has '_log' => (
    is => 'rw',
    isa => 'Object',
    default => sub { Log::Log4perl->get_logger($_[0]->log_category) },
    lazy => 1,
);

has '_svn_client' => (
    is => 'rw',
    isa => 'SVN::Client',
    default => sub { SVN::Client->new },
    lazy => 1,
);

before 'execute' => sub {
    my ($self) = @_;

    $self->_log->debug("Executing mirror operation");
};

after 'execute' => sub {
    my ($self) = @_;

    $self->_log->debug("Mirror operation finished");
};

before '_cd_run' => sub {
    my ($self, $path, $command, @args) = @_;

    $self->_log->debug("Path = [$path]");
    $self->_log->debug("Command = [$command @args]");
};

after '_cd_run' => sub {
    my ($self, $path) = @_;

    my $info;
    $self->_svn_client->info($path, undef, $self->revision, sub { $info = $_[1] }, 0);
    $self->_log->info("Mirroring " . $info->URL . ", revision " . $info->rev);
    $self->_log->debug("Last change: revision " . $info->last_changed_rev . " by " . $info->last_changed_author);
};

=head1 NAME

UFL::WebAdmin::SiteDeploy::Role::CommitLogger - Log information about the mirror operation

=head1 SYNOPSIS

    package SVN::Notify::Mirror::Logger;
    use Moose;
    with 'UFL::WebAdmin::SiteDeploy::Role::CommitLogger';

=head1 DESCRIPTION

This overrides L<SVN::Notify::Mirror/execute> and
L<SVN::Notify::Mirror/_cd_run> to log information about the mirror
operation.

Logging is performed via L<Log::Log4perl>. The logging category is
determined via the C<log_category> attribute.

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
