package DBIx::dbMan::Extension::SQLShowResult;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;
use Text::FormatTable;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000015-000001"; }

sub preference { return 0; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'SQL_RESULT') {
		if ($action{type} eq 'select') {
			$action{action} = 'SQL_OUTPUT';
			delete $action{processed};
		} elsif ($action{type} eq 'do') {
			if ($action{result} > -1) {
				$action{action} = 'OUTPUT';
				$action{output} = "Processed ".$action{result}." lines.\n" ;
			} else {
				$action{action} = 'NONE';
			}
		}
	}

	return %action;
}
