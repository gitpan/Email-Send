use ExtUtils::MakeMaker;

WriteMakefile (
               AUTHOR        => 'Casey West <casey@geeknest.com>',
               ABSTRACT      => "Simply Sending Email",
               NAME          => 'Email::Send',
               PREREQ_PM     => {
                                 'Email::Address' => '1.80',
                                 'Email::Simple' => '1.92',
                                 'Return::Value' => '1.28',
                                 'Test::More' => '0.47',
                                },
               VERSION_FROM  => 'lib/Email/Send.pm',
              );
