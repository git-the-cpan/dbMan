package DBIx::dbMan::Extension::CmdComments;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000077-000001"; }

sub preference { return 2500; }

sub known_actions { return [ qw/COMMAND/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^(rem(ark)?\s|--)/i) {
			$action{action} = 'NONE';
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'REMARK' => 'One-line comment'
	];
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return qw/REMARK/ if $line =~ /^\s*[A-Z]*$/i;
	return ();
}
