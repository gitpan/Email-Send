package Email::Send;
# $Id: Send.pm,v 1.7 2004/08/07 19:26:05 cwest Exp $
use strict;

use vars qw[$VERSION];
$VERSION   = '1.43';

use Carp qw[croak];
use Email::Simple;

=head1 NAME

Email::Send - Simply Sending Email

=head1 SYNOPSIS

  use Email::Send;
  send SMTP => <<'__MESSAGE__', $host;
  To: casey@geeknest.com
  From: foo@example.com

  Blah
  __MESSAGE__

  use Email::Send qw[Sendmail]; # preload mailer(s)
  my $email_obj = Email::Simple->new($msg);

  send Sendmail => $email_obj;

  my $mime_message = Simple::MIME->new(...);
  send IO => $mime_message, '-'; # print to STDOUT

  send My::Own::Special::Sender => $msg, %options;

=head1 DESCRIPTION

This module provides a very simple, very clean, very specific interface
to multiple Email mailers. The goal if this software is to be small
and simple, easy to use, and easy to extend.

=head2 Mailers

Mailers are simple to use. You can pre-load mailers when using C<Email::Send>.

  use Email::Send qw[SMTP NNTP];

If you don't preload a mailer before you use it in the C<send> function,
it will by dynamically loaded. Mailers are named either relative to the
C<Email::Send> namespace, or fully qualified. For example, when using
the C<IO> mailer, C<Email::Send> first tries to load C<Email::Send::IO>.
If that fails, an attempt is made to load C<IO>. If that final
attempt fails, C<Email::Send> will throw an exception.

=cut

sub import {
    my ($class, @mailers) = @_;
    {
      my $pkg = caller;
      no strict 'refs';
      *{"$pkg\::send"} = \&send;
    }
    return unless @mailers;
    _init_mailer($_) for @mailers;
}

=head2 Functions

=over 4

=item send

  my $rv = send $mailer => $message, @args;

This function tries to send C<$message> using C<$mailer>. C<$message> and
C<$mailer> are required arguments. Anything passed in C<@args> is passed
directly to C<$mailer>. Note that various mailers may require certain
arguments. Please consult the documentation for any mailer you choose
to use.

If C<Email::Abstract> is installed, the format of C<$message> is
specified exactly as anything that L<Email::Abstract|Email::Abstract>
can grok and return C<as_string>. This currently includes most email
building classes and a properly formatted message as a string. If you
have a message type that C<Email::Abstract> doesn't understand, read its
documentation for instructions on how to extend it.

Otherwise you may pass a message as a text string, or as an object whose
class is C<Email::Simple>, or inherits from C<Email::Simple> like
C<Email::MIME>.

=back

=cut

sub send ($$;@) {
    my ($mailer, $message, @args) = @_;
    my $package = _init_mailer($mailer);
    
    $message = _objectify_message($message);

    return unless defined $message;
    local $Carp::CarpLevel = -1;
    no strict 'refs';
    &{"$package\::send"}($message, @args);
}

sub _objectify_message {
    my $message = shift;

    return $message if UNIVERSAL::isa($message, 'Email::Simple');
    return Email::Simple->new($message) unless ref($message);
    return Email::Abstract->cast($message => 'Email::Simple')
      if eval 'require Email::Abstract';
    return undef;
}

sub _init_mailer {
    my ($mailer) = @_;
    local $Carp::CarpLevel = -1;
    my @mailers = ("Email::Send::$mailer", $mailer);
    for (@mailers) {
        eval "require $_";
        return $_ unless $@;
    }
    croak "Can't find mailer, tried (@mailers)";
}

1;

__END__

=head2 Writing Mailers

Writing new mailers is very simple. If you want to use a short name
when calling C<send>, name your mailer under the C<Email::Send> namespace.
If you don't, the full name will have to be used. A mailer only needs
to implement a single function, C<send>. It will be called from
C<Email::Send> exactly like this.

  Your::Sending::Package::send($message, @args);

C<$message> is an Email::Simple object, C<@args> are the extra
arguments passed into C<Email::Send::send>.

Here's an example of a mailer that sends email to a URL.

  package Email::Send::HTTP::Post;
  use strict;

  use vars qw[$AGENT $URL $FIELD];
  use Carp qw[croak];
  use LWP::UserAgent;

  sub send {
      my ($message, @args);
      if ( @args ) {
          my ($URL, $FIELD) = @args;
          $AGENT = LWP::UserAgent->new;
      }
      croak "Can't send to URL if no URL and field are named"
        unless $URL && $FIELD;
      $AGENT->post($URL => { $FIELD => $message->as_string });
  }

  1;

This example will keep a UserAgent singleton unless new arguments are
passed to C<send>. It is used by calling C<Email::Send::send>.

  send HTTP::Post => $message, 'http://example.com/incoming', 'message';
  send HTTP::Post => $message2; # uses saved $URL and $FIELD

=head1 SEE ALSO

L<Email::Abstract>,
L<Email::Send::IO>,
L<Email::Send::NNTP>,
L<Email::Send::Qmail>,
L<Email::Send::SMTP>,
L<Email::Send::Sendmail>,
L<perl>.

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>.

=head1 COPYRIGHT

  Copyright (c) 2004 Casey West.  All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the same terms as Perl itself.

=cut
