package DBIx::dbMan::Interface::cmdline;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Interface;
use DBIx::dbMan::History;
use Term::Size;

$VERSION = '0.02';
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

sub get_command {
	my $obj = shift;

	my $cmd = '';
	if ($obj->{readline}) {
		$cmd = $obj->{readline}->readline($obj->{-lang}->str($obj->get_prompt()));
		unless (defined $cmd) { $cmd = 'QUIT';  $obj->print("\n"); } 
		$obj->{history}->add($cmd);
	} else {
		$cmd = $obj->SUPER::get_command(@_);
	}

	return $cmd;
}

sub render_size {
	my $obj = shift;
	return Term::Size::chars(*STDOUT{IO})-1;
}

