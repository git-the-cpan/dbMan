package DBIx::dbMan::Extension::OutputPager;

use strict;
use base 'DBIx::dbMan::Extension';

our $VERSION = '0.03';

1;

sub IDENTIFICATION { return "000001-000037-000003"; }

sub preference { return -50; }

sub known_actions { return [ qw/OUTPUT/ ]; }

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
