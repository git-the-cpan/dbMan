package DBIx::dbMan::Extension::Quit;

use strict;
use base 'DBIx::dbMan::Extension';

our $VERSION = '0.07';

1;

sub IDENTIFICATION { return "000001-000003-000007"; }

sub preference { return 1000; }

sub known_actions { return [ qw/COMMAND/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND' 
		and $action{cmd} =~ /^(quit|exit|log ?out|\\q)$/i) {
			$action{action} = 'QUIT';
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		QUIT => 'Exit this program'
	];
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return qw/q/ if $line =~ /^\s*\\[A-Z]*$/i;
	return qw/QUIT EXIT LOGOUT \q/ if $line =~ /^\s*[A-Z]*$/i;
	return ();
}
