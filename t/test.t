use Test::More qw[no_plan];
# $Id: test.t,v 1.1 2004/05/28 02:18:16 cwest Exp $
use strict;
$^W =1;

BEGIN {
  use_ok 'Email::Send';
  use_ok 'Email::Send::IO';
  use_ok 'Email::Send::NNTP';
  use_ok 'Email::Send::Qmail';
  use_ok 'Email::Send::SMTP';
  use_ok 'Email::Send::Sendmail';
}

use Email::Simple;

my $message = Email::Simple->new(<<'__MESSAGE__');
To: me@myhost.com
From: you@yourhost.com
Subject: Test

Testing this thing out.
__MESSAGE__

send IO => $message, 'testfile';

my $test = do { local $/; open T, 'testfile'; <T> };

my $test_message = Email::Simple->new($test);

is $test_message->as_string, $message->as_string, 'sent properly';

unlink 'testfile';