package DBIx::dbMan::Extension::CmdHistory;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000034-000001"; }

sub preference { return 2000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^show(\s+commands?)?\s+history$/i) {
			$action{action} = 'HISTORY';
			$action{operation} = 'show';
		} elsif ($action{cmd} =~ /^(clear|erase)(\s+commands?)?\s+history$/i) {
			$action{action} = 'HISTORY';
			$action{operation} = 'clear';
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'SHOW HISTORY' => 'Show commands history',
		'CLEAR HISTORY' => 'Clear commands history'
	];
}

