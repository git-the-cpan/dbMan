package DBIx::dbMan::Extension::CmdSetOutputFormat;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.03';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000025-000003"; }

sub preference { return 1000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^set\s+output\s+format\s*(=|to\s)?\s*(.*)$/i) {
			my $want = lc $2;
			my @fmts = $obj->{-mempool}->get_register('output_format');
			my %fmts = ();
			for (@fmts) { ++$fmts{$_}; }
			$action{action} = 'OUTPUT';
			if ($fmts{$want}) {
				$obj->{-mempool}->set('output_format',$want);
				$action{output} = "Output format $want selected.\n";
			} else {
				$action{output} = "Unknown output format.\n".
					"Registered formats: ".(join ',',sort @fmts)."\n";
			}
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'SET OUTPUT FORMAT TO <format>' => 'Select another SQL output format'
	];
}

sub formatlist {
	my $obj = shift;
	return $obj->{-mempool}->get_register('output_format');
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return $obj->formatlist if $line =~ /^\s*SET\s+OUTPUT\s+FORMAT\s+TO\s+\S*$/i;
	return qw/TO/ if $line =~ /^\s*SET\s+OUTPUT\s+FORMAT\s+\S*$/i;
	return qw/FORMAT/ if $line =~ /^\s*SET\s+OUTPUT\s+\S*$/i;
	return qw/OUTPUT/ if $line =~ /^\s*SET\s+\S*$/i;
	return qw/SET/ if $line =~ /^\s*[A-Z]*$/i;
	return ();
}
