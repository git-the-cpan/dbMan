package DBIx::dbMan::Extension::Quit;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.04';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000003-000004"; }

sub preference { return 1000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND' 
		and $action{cmd} =~ /^(quit|exit|logout|\\q)$/i) {
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
	return qw/q/ if $line =~ /^\s*\\\S*$/i;
	return qw/QUIT EXIT LOGOUT \q/ if $line =~ /^\s*[A-Z]*$/i;
	return ();
}
