package DBIx::dbMan::Extension::Format;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000063-000001"; }

sub preference { return -75; }

sub handle_action {
	my ($obj,%action) = @_;

	if (exists $action{old_output_format}) {
		$obj->{-mempool}->set('output_format',$action{old_output_format});
	}

	$action{processed} = 1;
	return %action;
}
