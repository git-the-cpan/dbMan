package DBIx::dbMan::Extension::TrimCmd;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000006-000001"; }

sub preference { return 4000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		return %action if $action{cmd} =~ s/^\s+//;
		return %action if $action{cmd} =~ s/\s+$//;
	}

	$action{processed} = 1;
	return %action;
}
