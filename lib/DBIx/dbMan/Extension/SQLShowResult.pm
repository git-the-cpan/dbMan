package DBIx::dbMan::Extension::SQLShowResult;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;
use Text::FormatTable;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000015-000002"; }

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
				if ($action{result} ne '0E0') {
					$action{output} = "Processed ".$action{result}." line".(($action{result} == 1)?'':'s').".\n" ;
				} else {
					$action{output} = "Command processed.\n" ;
				}
			} else {
				$action{action} = 'NONE';
			}
		}
	}

	return %action;
}
