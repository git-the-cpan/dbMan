package DBIx::dbMan::Extension::SQLOutputNULL;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.05';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000029-000005"; }

sub preference { return 20; }

sub known_actions { return [ qw/SQL_OUTPUT/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'SQL_OUTPUT' and $obj->{-mempool}->get('output_format') ne 'plain' and $obj->{-mempool}->get('output_format') ne 'insert') {
		for my $outer (@{$action{result}}) {
			for (@$outer) {
				$_ = 'NULL' unless defined;
			}
		}
	}

	return %action;
}
