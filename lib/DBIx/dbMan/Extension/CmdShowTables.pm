package DBIx::dbMan::Extension::CmdShowTables;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000019-000001"; }

sub preference { return 2000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^(show\s+tables?|\\dt)$/i) {
			$action{action} = 'SHOW_TABLES';
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'SHOW TABLES' => 'Show tables in current connection'
	];
}

