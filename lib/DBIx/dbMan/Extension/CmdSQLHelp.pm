package DBIx::dbMan::Extension::CmdSQLHelp;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000058-000001"; }

sub preference { return 1000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^\\h\s+(.+)$/i) {
			$action{action} = 'HELP';
			$action{type} = 'sql';
			$action{what} = $1;
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'\h <sql>' => 'Show help for SQL command'
	];
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return ('\h') if $line =~ /^\s*$/i;
	return ('h') if $line =~ /^\s*\\[A-Z]*$/i;
	return ();
}
