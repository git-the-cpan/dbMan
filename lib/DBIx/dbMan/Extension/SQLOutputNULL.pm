package DBIx::dbMan::Extension::SQLOutputNULL;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000029-000001"; }

sub preference { return 0; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'SQL_OUTPUT') {
		for (@{$action{result}}) {
			for (@$_) {
				$_ = 'NULL' unless defined $_;
			}
		}
	}

	return %action;
}
