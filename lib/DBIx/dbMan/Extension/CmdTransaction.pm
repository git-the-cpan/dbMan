package DBIx::dbMan::Extension::CmdTransaction;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000021-000002"; }

sub preference { return 1500; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^(begin\s+(transaction|work)|\\tb)$/i) {
			$action{action} = 'TRANSACTION';
			$action{operation} = 'begin';
		} elsif ($action{cmd} =~ /^(end\s+(transaction|work)|\\ta|auto\s+(transaction|commit(\s+transaction)?))$/i) {
			$action{action} = 'TRANSACTION';
			$action{operation} = 'end';
		} elsif ($action{cmd} =~ /^(commit(\s+transaction)?|\\tc)$/i) {
			$action{action} = 'TRANSACTION';
			$action{operation} = 'commit';
		} elsif ($action{cmd} =~ /^(rollback(\s+transaction)?|\\tr)$/i) {
			$action{action} = 'TRANSACTION';
			$action{operation} = 'rollback';
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'BEGIN TRANSACTION' => 'Begin transaction block',
		'END TRANSACTION' => 'End transaction block, change to auto commit transaction',
		'COMMIT' => 'Commit transaction',
		'ROLLBACK' => 'Rollback transaction'
	];
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return () unless $obj->{-dbi}->current;
	return ('tc','tr','ta') if $line =~ /^\s*\\[A-Z]*$/i and $obj->{-dbi}->in_transaction;
	return ('tb') if $line =~ /^\s*\\[A-Z]*$/i and not $obj->{-dbi}->in_transaction;
	return ('\tc','\tr','\ta') if $line =~ /^\s*$/ and $obj->{-dbi}->in_transaction;
	return ('\tb') if $line =~ /^\s*$/ and not $obj->{-dbi}->in_transaction;
	return qw/TRANSACTION WORK/ if $line =~ /^\s*BEGIN\s+\S*$/i and not $obj->{-dbi}->in_transaction;
	return qw/TRANSACTION/ if $line =~ /^\s*AUTO\s+COMMIT\s+\S*$/i and $obj->{-dbi}->in_transaction;
	return qw/TRANSACTION COMMIT/ if $line =~ /^\s*AUTO\s+\S*$/i and $obj->{-dbi}->in_transaction;
	return qw/TRANSACTION WORK/ if $line =~ /^\s*(END|COMMIT|ROLLBACK)\s+\S*$/i and $obj->{-dbi}->in_transaction;
	return qw/BEGIN/ if $line =~ /^\s*[A-Z]*$/i and not $obj->{-dbi}->in_transaction;
	return qw/END AUTO COMMIT ROLLBACK/ if $line =~ /^\s*[A-Z]*$/i and $obj->{-dbi}->in_transaction;
	return ();
}
