package DBIx::dbMan::Extension::CmdSetBenchmark;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000050-000001"; }

sub preference { return 1000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^set\s+benchmark\s+(on|off)$/i) {
			my $want = lc $1;  my $owant = $want;
			$want = '' if $want eq 'off';
			$action{action} = 'OUTPUT';
			$obj->{-mempool}->set('benchmark',$want);
			$action{output} = "Benchmarking $owant.\n";
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'SET BENCHMARK [ON|OFF]' => 'Set benchmarking on or off.'
	];
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return qw/ON OFF/ if $line =~ /^\s*SET\s+BENCHMARK\s+\S*$/i;
	return qw/BENCHMARK/ if $line =~ /^\s*SET\s+\S*$/i;
	return qw/SET/ if $line =~ /^\s*[A-Z]*$/i;
	return ();
}
