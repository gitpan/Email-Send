use ExtUtils::MakeMaker;

WriteMakefile (
               AUTHOR        => 'Casey West <casey@geeknest.com>',
               ABSTRACT      => "Simply Sending Email",
               NAME          => 'Email::Send',
               PREREQ_PM     => {
                                 'Test::More'        => '0.47',
                                 'Email::Address'    => '',
                                 'Email::Simple'     => '',
                                },
               VERSION_FROM  => 'lib/Email/Send.pm',
              );
