package DBIx::dbMan::Extension::CmdStandardSQL;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000013-000001"; }

sub preference { return 1000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^(select|explain)\s+/i) {
			$action{action} = 'SQL';
			$action{type} = 'select';
			$action{sql} = $action{cmd};
		} elsif ($action{cmd} =~ /^(delete|insert|update|create|drop|begin|alter)\s+/i) {
			$action{action} = 'SQL';
			$action{type} = 'do';
			$action{sql} = $action{cmd};
		}
	}

	$action{processed} = 1;
	return %action;
}
