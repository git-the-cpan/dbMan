package DBIx::dbMan::Extension::DescribeCompleteOracle;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000049-000001"; }

sub preference { return 1000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'DESCRIBE' and $action{oper} eq 'complete') {
		$action{action} = 'NONE';
		unless ($obj->{-dbi}->current) {
			$obj->{-interface}->error("No current connection selected.");
			return %action;
		}	
		my $sth = $obj->{-dbi}->prepare(q!SELECT object_name FROM user_objects WHERE object_type IN ('TABLE','VIEW')!);
		$sth->execute();
		my $ret = $sth->fetchall_arrayref();
		my @all = ();
		@all = map { $_->[0] } @$ret if defined $ret;
		$sth->finish;
		$action{list} = \@all;
		$action{processed} = 1;
		return %action;
	}

	$action{processed} = 1;
	return %action;
}
