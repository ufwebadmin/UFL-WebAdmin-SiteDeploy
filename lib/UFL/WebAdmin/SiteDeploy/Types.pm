package UFL::WebAdmin::SiteDeploy::Types;

use Moose;
use Moose::Util::TypeConstraints;
use Path::Abstract;
use Path::Class::Dir;
use Path::Class::File;
use URI;

subtype 'Path::Abstract'
    => as 'Object'
    => where { $_->isa('Path::Abstract') };

coerce 'Path::Abstract'
    => from 'Str'
        => via { Path::Abstract->new($_) };


subtype 'Path::Class::Dir'
    => as 'Object'
    => where { $_->isa('Path::Class::Dir') };

coerce 'Path::Class::Dir'
    => from 'Str'
        => via { Path::Class::Dir->new($_) };


subtype 'Path::Class::File'
    => as 'Object'
    => where { $_->isa('Path::Class::File') };

coerce 'Path::Class::File'
    => from 'Str'
        => via { Path::Class::File->new($_) };


subtype 'URI'
    => as 'Object'
    => where { $_->isa('URI') };

coerce 'URI'
    => from 'Str'
        => via { URI->new($_) };

=head1 NAME

UFL::WebAdmin::SiteDeploy::Types - Type definitions for UFL::WebAdmin::SiteDeploy

=head1 SYNOPSIS

    use Moose;
    use UFL::WebAdmin::SiteDeploy::Types;

    has 'uri' => (
        is => 'rw',
        isa => 'URI',
        coerce => 1,
    );

=head1 DESCRIPTION

This class contains common L<Moose> type definitions for
L<UFL::WebAdmin::SiteDeploy>.

=head1 AUTHOR

Daniel Westermann-Clark E<lt>dwc@ufl.eduE<gt>

=head1 LICENSE

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
