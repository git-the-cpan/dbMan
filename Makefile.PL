# BEGIN { $^W = 1 }
BEGIN { require 5.003 }

use ExtUtils::MakeMaker;
use strict;

use FindBin;

# Some MakeMaker's forged some FileHandle methods
require FileHandle unless defined(&FileHandle::new);

eval 'use DBI';
if ($@) {
	print <<EOF;
You do not seem to have DBI installed, so you will not be able to use
retrieve and update database functions for dbMan.
EOF
} elsif (eval ' $DBI::VERSION < 1.12 ') {
	print <<EOF;
You have the DBI module, but it's the old version. Upgrade to at least 1.12
to use this with dbMan.
EOF
}

eval 'use Tk';
if ($@) {
	print <<EOF;
You do not seem to have Tk installed, so you will not be able to use this
software. Install Perl/Tk at least 800.014 version.
EOF
} elsif (eval ' $Tk::VERSION < 800.014 ') {
	print <<EOF;
You have the Tk module, but it's the old version. Upgrade to at least 800.014
to use this with dbMan.
EOF
}

my %opts = (
	NAME => 'dbMan',
	DISTNAME => 'dbMan',
	VERSION_FROM => 'bin/dbman',
	EXE_FILES => [ "bin/dbman" ],
	dist => { DIST_DEFAULT => 'tardist',
		  COMPRESS => 'gzip -9vf', SUFFIX => 'gz',
		  POSTOP => 'mv $(DISTNAME)-$(VERSION).tar.gz ../',
		},
);

if ($ExtUtils::MakeMaker::VERSION >= 5.43) {
	$opts{AUTHOR} = 'Milan Sorm (sorm@pef.mendelu.cz)';
	$opts{ABSTRACT} = 'Database management tool';
	$opts{PREREQ_PM} = { DBI => '1.12', Tk => 0, 'Locale::gettext' => 0 };
}

ExtUtils::MakeMaker::WriteMakefile(%opts);

exit 0;

package MY;

__END__

