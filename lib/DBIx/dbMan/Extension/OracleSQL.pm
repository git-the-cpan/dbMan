package DBIx::dbMan::Extension::OracleSQL;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000038-000002"; }

sub preference { return 3999; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND' and $obj->{-dbi}->driver eq 'Oracle') {
		$obj->{-dbi}->set('LongTruncOk',1);
		if ($action{cmd} !~ /end;$/i) {
			return %action if $action{cmd} =~ s/[;\/]$//;
		}
	}

	$action{processed} = 1;
	return %action;
}
