
use strict;
use warnings;

use 5.005;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Simply Sending Email",
  "AUTHOR" => "Casey West <casey\@geeknest.com>",
  "BUILD_REQUIRES" => {},
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "Email-Send",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "Email::Send",
  "PREREQ_PM" => {
    "Email::Abstract" => "0",
    "Email::Address" => "1.80",
    "Email::Simple" => "1.92",
    "File::Spec" => "0",
    "Module::Pluggable" => "2.97",
    "Net::SMTP" => "0",
    "Return::Value" => "0",
    "Scalar::Util" => "1.02",
    "Symbol" => "0",
    "strict" => "0",
    "vars" => "0"
  },
  "TEST_REQUIRES" => {
    "Capture::Tiny" => "0",
    "Cwd" => "0",
    "File::Path" => "0",
    "File::Temp" => "0",
    "MIME::Entity" => "0",
    "Mail::Internet" => "0",
    "Test::More" => "0.88",
    "blib" => "0",
    "lib" => "0",
    "warnings" => "0"
  },
  "VERSION" => "2.199",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  my $tr = delete $WriteMakefileArgs{TEST_REQUIRES};
  my $br = $WriteMakefileArgs{BUILD_REQUIRES};
  for my $mod ( keys %$tr ) {
    if ( exists $br->{$mod} ) {
      $br->{$mod} = $tr->{$mod} if $tr->{$mod} > $br->{$mod};
    }
    else {
      $br->{$mod} = $tr->{$mod};
    }
  }
}

unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



