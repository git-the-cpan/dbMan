package DBIx::dbMan::Extension::TotalCount;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000073-000001"; }

sub preference { return -30; }

sub known_actions { return [ qw/OUTPUT/ ]; }

sub init {
	my $obj = shift;
	$obj->{-mempool}->set('total_count',1);
}

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'OUTPUT' and $action{type} eq 'select' and $action{sql} and $obj->{-mempool}->get('total_count')) {
		my $num = scalar @{$action{result}};
		my $cols = scalar @{$action{fieldnames}};
		$action{output} .= ($num==0?"No":"Total $num")." line".($num==1?"":"s")." of output in $cols column".($cols==1?"":"s").".\n";
	}

	return %action;
}
