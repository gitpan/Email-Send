use ExtUtils::MakeMaker;

WriteMakefile (
               AUTHOR        => 'Casey West <casey@geeknest.com>',
               ABSTRACT      => "Simply Sending Email",
               NAME          => 'Email::Send',
               PREREQ_PM     => {
                                 'Test::More'        => '',
                                 'Email::Address'    => '',
                                 'Email::Abstract'   => '',
                                },
               VERSION_FROM  => 'lib/Email/Send.pm',
              );
