package DBIx::dbMan::Extension::CmdHelp;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000009-000002"; }

sub preference { return 1000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^help$/i) {
			$action{action} = 'HELP';
			$action{type} = 'commands';
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'HELP' => 'Show this help'
	];
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return qw/HELP/ if $line =~ /^\s*[A-Z]*$/i;
	return ();
}
