package DBIx::dbMan::Interface::cmdline;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Interface;
use DBIx::dbMan::History;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Interface/;

1;

sub init {
	my $obj = shift;

	$obj->SUPER::init(@_);
	eval {
		require Term::ReadLine;
	};
	$obj->{readline} = new Term::ReadLine 'dbMan' unless $@;
	
	if ($obj->{readline}) {
		$obj->{history} = new DBIx::dbMan::History 
			-config => $obj->{-config};
		for ($obj->{history}->load()) {
			$obj->{readline}->addhistory($_);
		}
	}
}

sub prompt {
	my $obj = shift;

	unless ($obj->{readline}) {
		return $obj->SUPER::prompt(@_);
	}
}

sub get_command {
	my $obj = shift;

	my $cmd = '';
	if ($obj->{readline}) {
		$cmd = $obj->{readline}->readline($obj->{-lang}->str('SQL: '));
		unless (defined $cmd) { $cmd = 'QUIT';  $obj->print("\n"); } 
		$obj->{history}->add($cmd);
	} else {
		$cmd = $obj->SUPER::get_command(@_);
	}

	return $cmd;
}

