package Email::Send::SMTP;
# $Id: SMTP.pm,v 1.1 2004/05/28 02:18:16 cwest Exp $
use strict;

use vars qw[$VERSION $SMTP];
$VERSION = (qw$Revision: 1.1 $)[1];
use Net::SMTP;
use Email::Address;

sub send {
    my ($message, @args) = @_;
    if ( @_ > 1 ) {
        $SMTP->quit if $SMTP;
        $SMTP = Net::SMTP->new(@args);
        return unless $SMTP;
    }
    $SMTP->mail( (Email::Address->parse($message->header('From')))[0]->address );
    $SMTP->to(   (Email::Address->parse($message->header('To'  )))[0]->address );
    return unless $SMTP->data( $message->as_string );
    return 1;
}

sub DESTROY {
    $SMTP->quit if $SMTP;
}

1;

__END__

=head1 NAME

Email::Send::SMTP - Send Messages using SMTP

=head1 SYNOPSIS

  use Email::Send;

  send SMTP => $message, 'smtp.example.com';

=head1 DESCRIPTION

This mailer for C<Email::Send> uses C<Net::SMTP> to send a message with
an SMTP server. The first invocation of C<send> requires an SMTP server
arguments. Subsequent calls will remember the the first setting until
it is reset.

Any arguments passed to C<send> will be passed to C<Net::SMTP->new>.

=head1 SEE ALSO

L<Email::Send>,
L<Net::SMTP>,
L<Email::Address>,
L<perl>.

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>.

=head1 COPYRIGHT

  Copyright (c) 2004 Casey West.  All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the same terms as Perl itself.

=cut
