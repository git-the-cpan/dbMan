package DBIx::dbMan::Extension::Output;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000016-000001"; }

sub preference { return -100; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'OUTPUT') {
		$obj->{-interface}->print($action{output});
		$action{action} = 'NONE';
	}

	$action{processed} = 1;
	return %action;
}
