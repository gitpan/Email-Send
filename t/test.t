use Test::More qw[no_plan];
# $Id: test.t,v 1.3 2004/07/30 01:39:42 cwest Exp $
use strict;
$^W =1;

BEGIN {
  use_ok 'Email::Send';
}

use Email::Simple;

if ( eval "require IO::All" ) {
    {
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
    }
    {
        my $message = Email::Simple->new(<<'__MESSAGE__');
To: me@myhost.com
From: you@yourhost.com
Subject: Test
    
Testing this thing out.
__MESSAGE__
    
        my $message_text = $message->as_string;
        
        send IO => $message_text, 'testfile';
    
        my $test = do { local $/; open T, 'testfile'; <T> };
    
        my $test_message = Email::Simple->new($test);
    
        is $test_message->as_string, $message->as_string, 'sent properly';
    
        unlink 'testfile';
    }
}
