package DBIx::dbMan::Extension::CmdOutputToFile;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000017-000001"; }

sub preference { return 2000; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ s/^\\s(c)?\((.*?)\)\s+//i) {
			$action{output_save_copy} = $1;
			$action{output_device} = $2;
			delete $action{processed};
		}
	}

	return %action;
}

sub cmdhelp {
	return [
		'\s(<file>) <command>' => 'Save output of <command> to <file>',
		'\sc(<file>) <command>' => 'Save copy of output of <command> to <file>'
	];
}
