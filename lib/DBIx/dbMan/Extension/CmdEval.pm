package DBIx::dbMan::Extension::CmdEval;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000071-000001"; }

sub preference { return 1000; }

sub known_actions { return [ qw/COMMAND/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ s/^eval\s+//i) {
			$action{action} = 'EVAL';
			$action{type} = 'perl';
			$action{what} = $action{cmd};
		} elsif ($action{cmd} =~ s/^system\s+//i) {
			$action{action} = 'EVAL';
			$action{type} = 'system';
			$action{what} = $action{cmd};
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return qw/EVAL SYSTEM/ if $line =~ /^\s*[A-Z]*$/i;
}

sub cmdhelp {
	my $obj = shift;

	return [ 'EVAL <commands>' => 'Evaluate Perl commands',
		 'SYSTEM <command>' => 'Evaluate shell expression' ];
}
