package DBIx::dbMan::Config;

use strict;
use vars qw/$VERSION @ISA $AUTOLOAD/;
use locale;
use POSIX;

$VERSION = '0.01';

1;

sub new {
	my $class = shift;
	my $obj = bless { @_ }, $class;

	$obj->{config} = {};
	$obj->{configfile} = $obj->configfile();
	$obj->load if $obj->{configfile};

	return $obj;
}

sub bhashes {
	my $line = shift;

	$line =~ s/#/\\#/g;
	return $line;
}

sub load {
	my $obj = shift;
	if (open F,$obj->{configfile}) {
		while (<F>) {
			my $key;  my $value;
			chomp;
			s/\\/\\\\/g;			# double backslashes
			s/^(['"])(.*?)([^\\])\1/$1.(bhashes($2.$3)).$1/eg;
			s/([^\\])(['"])(.*?)([^\\])\2/$1.$2.(bhashes($3.$4)).$2/eg;
					# backslash # in ''
			s/^#.*$//;			# whole-line comment
			s/([^\\])#.*$/$1/;		# other comment
			s/\\#/#/g;			# unbackslash #
			s/\\\\/\\/g;			# single backslashes
			s/^\s+//;			# starting whitespaces
			s/\s+$//;			# ending whitespaces
			next unless $_;			# empty line
			if (/^(\S+)\s+(.*)$/) {
				($key,$value) = ($1,$2);
			} else {
				($key,$value) = ($_,'');
			}
			$value =~ s/^(['"])(.*)\1$/$2/;	# quoted line
			push @{$obj->{config}->{$key}},$value;
				
		}
		close F;
	}
}

sub configfile {
	my $obj = shift;
	
	my $res = $ENV{DBMAN_CONFIG};
	return $res if $res and -e $res;

	$res = $ENV{HOME}.'/.dbman/config';
	return $res if -e $res;

	return '/etc/dbman.conf';
}

sub AUTOLOAD {
	my $obj = shift;

	$AUTOLOAD =~ s/^DBIx::dbMan::Config:://;
	my $res = $obj->{config}->{$AUTOLOAD};
	if (defined $res) {
		if (ref $res and scalar @$res > 1) {
			return wantarray ? @$res : $res;
		} else {
			return wantarray ? @$res : $res->[0];
		}
	} else {
		return undef;
	}
}
