package Email::Send::IO;
# $Id: IO.pm,v 1.1 2004/05/28 02:18:16 cwest Exp $
use strict;

use vars qw[$VERSION @IO];
$VERSION = (qw$Revision: 1.1 $)[1];
@IO      = ('=');

use IO::All;

sub send {
    my ($message, @args) = @_;
    @args = (@IO) unless @args;
    eval {io(@args) << $message->as_string};
}

1;

__END__

=head1 NAME

Email::Send::IO - Send messages using IO operations

=head1 SYNOPSIS

  use Email::Send;

  send IO => $message; # To STDERR

  send IO => $message, 'filename.txt'; # append to the file

=head1 DESCRIPTION

This is a mailer for C<Email::Send> that will send a message using IO
operations. By default it sends mail to STDERR, very useful for debugging.
The IO functionality is built upon C<IO::All>. Any additional arguments
passed to C<send> will be used as arguments to C<IO::All::io>.

You can globally change where IO is sent by modifying the C<@Email::Send::IO::IO>
package variable.

  @Email::Send::IO::IO = ('-'); # always append to STDOUT.

=head2 Examples

Sending to STDOUT.

  send IO => $message, '-';

Send to a socket.

  send IO => $message, 'server:1337';

=head1 SEE ALSO

L<Email::Send>,
L<IO::All>,
L<perl>.

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>.

=head1 COPYRIGHT

  Copyright (c) 2004 Casey West.  All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the same terms as Perl itself.

=cut
