package DBIx::dbMan::Lang;

use strict;
use vars qw/$VERSION/;
use locale;
use POSIX;
use Locale::gettext;

$VERSION = '0.01';

1;

sub new {
	my $class = shift;
	my $obj = bless { @_ }, $class;
	setlocale(LC_MESSAGES, "");
	textdomain('dbman');
	return $obj;
}

sub str {
	my $obj = shift;
	my $str = join '',@_;
	return gettext $str;
}
