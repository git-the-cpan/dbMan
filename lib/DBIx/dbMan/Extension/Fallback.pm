package DBIx::dbMan::Extension::Fallback;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000002-000001"; }

sub preference { return -1000; }

sub handle_action {
	my ($obj,%action) = @_;

	# Not handled command
	if ($action{action} eq 'COMMAND') {
		$obj->{-interface}->print("Unknown command.\n");
		$action{action} = 'NONE';
	}

	$action{processed} = 1;
	return %action;
}
