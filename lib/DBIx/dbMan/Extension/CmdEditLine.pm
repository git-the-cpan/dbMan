package DBIx::dbMan::Extension::CmdEditLine;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000068-000001"; }

sub preference { return 1000; }

sub known_actions { return [ qw/COMMAND/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^\s*\\e(?:\s+(.*))?\s*$/i) {
			$action{action} = 'EDIT_LINE';
			$action{what} = $1 || '';
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'\e [<line>]' => 'Edit <line> or create new line'
		];
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return ('\e') if $line =~ /^\s*$/i;
	return ('e') if $line =~ /^\s*\\[A-Z]*$/i;
	return ();
}
