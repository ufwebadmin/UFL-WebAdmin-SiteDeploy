package UFL::WebAdmin::SiteDeploy::Role::CommitLogger;

use Moose::Role;
use Log::Log4perl;

# XXX: See http://search.cpan.org/dist/Moose/lib/Moose/Role.pm#CAVEATS
#requires 'log_category';

has '_log' => (
    is => 'rw',
    isa => 'Object',
    default => sub { Log::Log4perl->get_logger($_[0]->log_category) },
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

around '_cd_run' => sub {
    # Capture any output from SVN::Notify::Mirror
    my $next = shift;
    my @output = $next->(@_);

    my $self = shift;

    # XXX: Not sure if the return code is eaten somewhere in SVN::Notify::Mirror
    $self->_log->debug("Return code = [$?]");

    my $message = @output ? "Output = [" . join("\n", @output) . "]" : "(No output from command)";
    $self->_log->debug($message);

    return @output;
};

after '_cd_run' => sub {
    my ($self, $path) = @_;

    my $client = SVN::Client->new;

    my $info;
    $client->info($path, undef, $self->revision, sub { $info = $_[1] }, 0);

    # XXX: This may be confusing since the log implies we're still doing the operation, but this method runs after
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
