package DBIx::dbMan::Extension::SQLOracleOutput;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000060-000002"; }

sub preference { return -35; }

sub known_actions { return [ qw/OUTPUT/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'OUTPUT' and $action{oracle_dbms}) {
		my $dbms = join "\n",$obj->{-dbi}->func('dbms_output_get');
		$dbms = "DBMS output:\n$dbms\n" if $dbms;
		$action{output} .= $dbms;
	}

	return %action;
}
