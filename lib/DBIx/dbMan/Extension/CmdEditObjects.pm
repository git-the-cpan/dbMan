package DBIx::dbMan::Extension::CmdEditObjects;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000042-000001"; }

sub preference { return 1000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^edit\s+(?:(.*)\s+)?(\S+)$/i) {
			$action{action} = 'EDIT_OBJECT';
			$action{type} = $1;
			$action{what} = $2;
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'EDIT <objectname>' => 'Edit object with <objectname>'
		];
}
