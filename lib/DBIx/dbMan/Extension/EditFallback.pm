package DBIx::dbMan::Extension::EditFallback;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000044-000002"; }

sub preference { return -100; }

sub known_actions { return [ qw/EDIT_OBJECT/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;

	if ($action{action} eq 'EDIT_OBJECT') {
		$action{action} = 'OUTPUT';
		$action{output} = "I can't edit $action{what}".($action{type}?" (type $action{type})":"").".\n";
		delete $action{processed};
	}

	return %action;
}
