package DBIx::dbMan::History;

use strict;
use vars qw/$VERSION/;
use locale;
use POSIX;
use DBIx::dbMan::Config;

$VERSION = '0.01';

1;

sub new {
	my $class = shift;
	my $obj = bless { @_ }, $class;
	return $obj;
}

sub load {
	my $obj = shift;

	my $file = $obj->historyfile;

	return () unless $file;
	
	my @lines = ();

	if (open F,$file) {
		while (<F>) {
			chomp;
			push @lines,$_;
		}	
		close F;
	}
	return @lines;
}

sub historyfile {
	my $obj = shift;
	
	return $ENV{DBMAN_HISTORY} if $ENV{DBMAN_HISTORY};
	return $obj->{-config}->history if $obj->{-config}->history;
	mkdir $ENV{HOME}.'/.dbman' unless -d $ENV{HOME}.'/.dbman';
	return $ENV{HOME}.'/.dbman/history';
}

sub add {
	my $obj = shift;
	my $line = join "\n",@_;

	my $file = $obj->historyfile;
	return unless $file;
	
	if (open F,">>$file") {
		print F "$line\n";
		close F;
	}
}
