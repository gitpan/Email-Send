package Email::Send;
# $Id: Send.pm,v 1.13 2005/05/11 03:14:14 cwest Exp $
use strict;

use vars qw[$VERSION];
$VERSION   = '1.99_01';

use base qw[Class::Accessor::Fast];
use Email::Simple;
use Module::Pluggable search_path => 'Email::Send';
use UNIVERSAL::require;
use Return::Value;

=head1 NAME

Email::Send - Simply Sending Email

=head1 SYNOPSIS

  use Email::Send;

  my $message = <<'__MESSAGE__';
  To: recipient@example.com
  From: sender@example.com
  Subject: Hello there folks
  
  How are you? Enjoy!
  __MESSAGE__

  my $sender = Email::Send->new({mailer => 'SMTP'});
  $sender->mailer_args([Host => 'smtp.example.com']);
  $sender->send($message);
  
  # more complex
  my $bulk = Email::Send->new;
  for ( qw[SMTP Sendmail Qmail] ) {
      $bulk->mailer($_) and last if $bulk->mailer_available($_);
  }

  $bulk->message_modifier(sub {
      my ($sender, $message, $to) = @_;
      $message->header_set(To => qq[$to\@geeknest.com])
  });
  
  my @to = qw[casey chastity evelina casey_jr marshall];
  my $rv = $bulk->send($message, $_) for @to;

=head1 DESCRIPTION

This module provides a very simple, very clean, very specific interface
to multiple Email mailers. The goal if this software is to be small
and simple, easy to use, and easy to extend.

=head2 Constructors

=over 4

=item new()

  my $mailer = Email::Send->new({
      mailer      => 'NNTP',
      mailer_args => [ Host => 'nntp.example.com' ],
  });

Create a new mailer object. This method can take parameters for any of the data
properties of this module. Those data properties, which have their own accessors,
are listed under L<"Properties">.

=back

=head2 Properties

=over 4

=item mailer

The mailing system you'd like to use for sending messages with this object.
This is not defined by default. If you don't specify a mailer, all available
plugins will be tried when the C<send()> method is called until one succeeds.

=item mailer_args

Arguments passed into the mailing system you're using.

=item message_modifier

If defined, this callback is invoked every time the C<send()> method is called
on an object. The mailer object will be passed as the first argument. Second,
the actual C<Email::Simple> object for a message will be passed. Finally, any
additional arguments passed to C<send()> will be passed to this method in the
order they were recieved.

This is useful if you are sending in bulk.

=back

=cut

sub new {
    my ($class, $args) = @_;
    $args->{mailer_args} ||= [];
    my %plugins = map {
	                   my ($short_name) = /^Email::Send::(.+)/;
		               ($short_name, $_);
		              } $class->plugins;
	$args->{_plugin_list} = \%plugins;
    return $class->SUPER::new($args);
}
__PACKAGE__->mk_accessors(qw[mailer mailer_args message_modifier _plugin_list]);

=head2 Methods

=over 4

=item send()

  my $result = $mailer->send($message, @modifier_args);

Send a message using the predetermined mailer and mailer arguments. If you
have defined a C<message_modifier> it will be called prior to sending.

The first argument you pass to send is an email message. It must be in some
format that C<Email::Abstract> can understand. If you don't have C<Email::Abstract>
installed then sending as plain text or an C<Email::Simple> object will do.

Any remaining arguments will be passed directly into your defined
C<message_modifier>.

=cut

sub send {
    my ($self, $message, @args) = @_;
    my $simple = $self->_objectify_message($message);
    return failure "No message found." unless $simple;

	$self->message_modifier(
		$self, $simple,
		@args,
	) if $self->message_modifier;

	if ( $self->mailer ) {
		return $self->_send_it($self->mailer, $simple);
	}

	return $self->_try_all($simple);
}

=item all_mailers()

  my @available = $mailer->all_mailers;

Returns a list of availabe mailers. These are mailers that are
installed on your computer and register themselves as available.

=cut

sub all_mailers {
	my ($self) = @_;
	my @mailers;
	for ( keys %{$self->_plugin_list} ) {
		push @mailers, $_ if $self->mailer_available($_);
	}
	return @mailers;
}

=item mailer_available()

  # is SMTP over SSL avaialble?
  $mailer->mailer('SMTP')
    if $mailer->mailer_available('SMTP', ssl => 1);

Given the name of a mailer, such as C<SMTP>, determine if it is
available. Any additional arguments passed to this method are passed
directly to the C<is_available()> method of the mailer being queried.

=back

=cut

sub mailer_available {
	my ($self, $mailer, @args) = @_;
	if ( my $package = $self->_plugin_list->{$mailer} ) {
	    $package->require or return failure;
	    $package->can('is_available')
	      or return failure "Mailer $mailer doesn't report availability.";
		my $test = $package->is_available(@args);
		return $test unless $test;
		return success;
	}
	return failure "Mailer $mailer not found.";
}

sub _objectify_message {
    my ($self, $message) = @_;

    return $message if UNIVERSAL::isa($message, 'Email::Simple');
    return Email::Simple->new($message) unless ref($message);
    return Email::Abstract->cast($message => 'Email::Simple')
      if Email::Abstract->require;
    return undef;
}

sub _send_it {
	my ($self, $mailer, $message) = @_;
	my $test = $self->mailer_available($mailer);
	return $test unless $test;

    my $package = $self->_plugin_list->{$mailer};
    $package->require or return failure;
	return $package->send($message, @{$self->mailer_args});
}

sub _try_all {
	my ($self, $simple) = @_;
	foreach ( $self->all_mailers ) {
		my $sent = $self->_send_it($_, $simple);
		return $sent if $sent;
	}
	return failure "Unable to send message.";
}

1;

__END__

=head2 Writing Mailers

  package Email::Send::Example;

  use UNIVERSAL::require;

  sub is_available {
      Net::Example->require;
  }

  sub send {
      my ($class, $message, @args) = @_;
      Net::Example->require;
      Net::Example->do_it($message) or return;
  }
  
  1;

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
  use UNIVERSAL::require;
  use Return::Value;
  
  sub is_available {
	  LWP::UserAgent->require;
  }

  sub send {
      my ($message, @args);

	  LWP::UserAgent->require;

      if ( @args ) {
          my ($URL, $FIELD) = @args;
          $AGENT = LWP::UserAgent->new;
      }
      return failure "Can't send to URL if no URL and field are named"
        unless $URL && $FIELD;
      $AGENT->post($URL => { $FIELD => $message->as_string });
	  return success;
  }

  1;

This example will keep a UserAgent singleton unless new arguments are
passed to C<send>. It is used by calling C<Email::Send::send>.

  my $mailer = Email::Send->new({ mailer => 'HTTP::Post' });
  
  $mailer->mailer_args([ 'http://example.com/incoming', 'message' ]);

  $mailer->send($message);
  $mailer->send($message2); # uses saved $URL and $FIELD

=head1 SEE ALSO

L<Email::Simple>,
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

  Copyright (c) 2005 Casey West.  All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the same terms as Perl itself.

=cut
