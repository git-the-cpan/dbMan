package DBIx::dbMan::Extension::CmdSetDBMS;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000067-000001"; }

sub preference { return 1000; }

sub known_actions { return [ qw/COMMAND/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^set\s+serveroutput\s+(on|off)$/i) {
			my $want = lc $1;  my $owant = $want;
			$want = ($want eq 'off')?0:1;
			$obj->{-mempool}->set('dbms_output',$want);
			$action{action} = 'OUTPUT';
			$action{output} = "Serveroutput $owant.\n";
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'SET SERVEROUTPUT [ON|OFF]' => 'Set serveroutput on or off.'
	];
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return qw/ON OFF/ if $line =~ /^\s*SET\s+SERVEROUTPUT\s+\S*$/i;
	return qw/SERVEROUTPUT/ if $line =~ /^\s*SET\s+\S*$/i;
	return qw/SET/ if $line =~ /^\s*[A-Z]*$/i;
	return ();
}
