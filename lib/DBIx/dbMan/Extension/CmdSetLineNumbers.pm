package DBIx::dbMan::Extension::CmdSetLineNumbers;

use strict;
use base 'DBIx::dbMan::Extension';

our $VERSION = '0.02';

1;

sub IDENTIFICATION { return "000001-000075-000002"; }

sub preference { return 1000; }

sub known_actions { return [ qw/COMMAND/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^set\s+(?:auto\s*)?line\s*number(?:s|ing)\s+(on|off)$/i) {
			my $want = lc $1;  my $owant = $want;
			$want = ($want eq 'off')?0:1;
			$obj->{-mempool}->set('line_numbers',$want);
			$action{action} = 'OUTPUT';
			$action{output} = "Auto line numbering $owant.\n";
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'SET LINE NUMBERING [ON|OFF]' => 'Set auto line numbering on or off.'
	];
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return qw/ON OFF/ if $line =~ /^\s*SET\s+LINE\s+NUMBERING\s+\S*$/i;
	return qw/NUMBERING/ if $line =~ /^\s*SET\s+LINE\s+\S*$/i;
	return qw/LINE/ if $line =~ /^\s*SET\s+\S*$/i;
	return qw/SET/ if $line =~ /^\s*[A-Z]*$/i;
	return ();
}
