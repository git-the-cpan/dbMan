package DBIx::dbMan::Extension::Fallback;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000002-000002"; }

sub preference { return -99999; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;

	# Not handled command
	if ($action{action} eq 'COMMAND') {
		$action{action} = 'OUTPUT';
		$action{output} = "Unknown command.\n";
		delete $action{processed};
	} elsif (not $action{action}) {	# internal - incorrect handling of action
		$obj->{-interface}->print("INTERNAL: Action not correctly handled by some extension!\n");
	} elsif ($action{action} ne 'NONE' and $action{action} ne 'QUIT') {  # internal - action not handled
		$obj->{-interface}->print("INTERNAL: Not handled action $action{action}.\n");
		$action{action} = 'NONE';
	}

	return %action;
}
