package Email::Send::NNTP;
# $Id: NNTP.pm,v 1.1 2004/05/28 02:18:16 cwest Exp $
use strict;

use vars qw[$VERSION $NNTP];
use Net::NNTP;

sub send {
    my ($message, @args) = @_;
    if ( @_ > 1 ) {
        $NNTP->quit if $NNTP;
        $NNTP = Net::NNTP->new(@args);
        return unless $NNTP;
    }
    return unless $NNTP->post( $message->as_string );
    return 1;
}

sub DESTROY {
    $NNTP->quit if $NNTP;
}

1;

__END__

=head1 NAME

Email::Send::NNTP - Post Messages to a News Server

=head1 SYNOPSIS

  use Email::Send;

  send NNTP => $message, 'news.example.com';

=head1 DESCRIPTION

This is a mailer for C<Email::Send> that will post a message to a news server.
The message must be formatted properly for posting. Namely, it must contain a
I<Newsgroups:> header. At least the first invocation of C<send> requires
a news server arguments. After the first declaration the news server will
be remembered until such time as you pass another one in.

=head1 SEE ALSO

L<Email::Send>,
L<Net::NNTP>,
L<perl>.

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>.

=head1 COPYRIGHT

  Copyright (c) 2004 Casey West.  All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the same terms as Perl itself.

=cut
