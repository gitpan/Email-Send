package Email::Send::SMTP;
# $Id: SMTP.pm,v 1.4 2004/07/20 22:11:46 cwest Exp $
use strict;

use vars qw[$VERSION $SMTP];
$VERSION = (qw$Revision: 1.4 $)[1];
use Net::SMTP;
use Email::Address;

sub send {
    my ($message, @args) = @_;
    if ( @_ > 1 ) {
        my %args;
        if ( @args % 2 ) {
            my $host = shift @args;
            %args = @args;
            $args{Host} = $host;
        } else {
            %args = @args;
        }

        if ( $args{ssl} ) {
            require Net::SMTP::SSL;
            $SMTP->quit if $SMTP;
            $SMTP = Net::SMTP::SSL->new(%args);
            return unless $SMTP;
        } else {
            $SMTP->quit if $SMTP;
            $SMTP = Net::SMTP->new(%args);
            return unless $SMTP;
        }
        
        my ($user, $pass)
          = @args{qw[username password]};
        $SMTP->auth($user, $pass) if $user;
    }
    $SMTP->mail( (Email::Address->parse($message->header('From')))[0]->address );

    $SMTP->to( (map $_->address, Email::Address->parse($message->header('To' )),
                                 Email::Address->parse($message->header('Cc' )),
                                 Email::Address->parse($message->header('Bcc')) ),
               { SkipBad => 1 },
             ) || return;

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

Any arguments passed to C<send> will be passed to C<< Net::SMTP->new() >>,
with some exceptions. C<username> and C<password>, if passed, are
used to invoke C<< Net::SMTP->auth() >> for SASL authentication support.
C<ssl>, if set to true, turns on SSL support by using C<Net::SMTP::SSL>.

=head1 SEE ALSO

L<Email::Send>,
L<Net::SMTP>,
L<Net::SMTP::SSL>,
L<Email::Address>,
L<perl>.

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>.

=head1 COPYRIGHT

  Copyright (c) 2004 Casey West.  All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the same terms as Perl itself.

=cut
