package DBIx::dbMan::Extension::CmdPager;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000036-000001"; }

sub preference { return 2000; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ s/^\\p\s+//i) {
			++$action{output_pager};
			delete $action{processed};
		}
	}

	return %action;
}

sub cmdhelp {
	return [
		'\p <command>' => 'Pager <command> (like less or more)',
	];
}
