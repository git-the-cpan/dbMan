package DBIx::dbMan::Extension::EditFallback;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000044-000001"; }

sub preference { return -100; }

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
