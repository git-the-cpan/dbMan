package DBIx::dbMan::Extension::CmdSetDBMS;

use strict;
use base 'DBIx::dbMan::Extension';

our $VERSION = '0.03';

1;

sub IDENTIFICATION { return "000001-000067-000003"; }

sub preference { return 1000; }

sub known_actions { return [ qw/COMMAND/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^set\s+server\s*output\s+(on|off)$/i) {
			my $want = lc $1;  my $owant = $want;
			$want = ($want eq 'off')?0:1;
			$obj->{-mempool}->set('dbms_output',$want);
			$action{action} = 'OUTPUT';
			$action{output} = "Server output $owant.\n";
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'SET SERVER OUTPUT [ON|OFF]' => 'Set server output on or off.'
	];
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return qw/ON OFF/ if $line =~ /^\s*SET\s+SERVER\s+OUTPUT\s+\S*$/i;
	return qw/OUTPUT/ if $line =~ /^\s*SET\s+SERVER\s+\S*$/i;
	return qw/SERVER/ if $line =~ /^\s*SET\s+\S*$/i;
	return qw/SET/ if $line =~ /^\s*[A-Z]*$/i;
	return ();
}
