package DBIx::dbMan::Extension::CmdSetOutputFormat;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000025-000001"; }

sub preference { return 1000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^set output format\s*(=|to)?\s*(.*)$/i) {
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
