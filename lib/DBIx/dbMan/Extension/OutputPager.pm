package DBIx::dbMan::Extension::OutputPager;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000037-000001"; }

sub preference { return -50; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'OUTPUT' and $action{output_pager}) {
		open F,"|less";
		print F $action{output};
		close F;
		$action{action} = 'NONE';
	}

	$action{processed} = 1;
	return %action;
}
