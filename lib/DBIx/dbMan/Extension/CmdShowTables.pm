package DBIx::dbMan::Extension::CmdShowTables;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000019-000002"; }

sub preference { return 2000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^(?:show\s+(object|table|view|sequence)s?|\\dt)(?:\s+(\S+))?$/i) {
			$action{action} = 'SHOW_TABLES';
			$action{type} = lc $1;
			$action{mask} = uc $2;
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'SHOW [OBJECTS|TABLES|VIEWS|SEQUENCES] [<RE-filter>]' => 'Show tables/views/sequences/all objects in current connection'
	];
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return () unless $obj->{-dbi}->current;
	return qw/OBJECTS TABLES VIEWS SEQUENCES/ if $line =~ /^\s*SHOW\s+\S*$/i;
	return ('SHOW','\dt') if $line =~ /^\s*$/;
	return ('dt') if $line =~ /^\s*\\[A-Z]*$/i;
	return qw/SHOW/ if $line =~ /^\s*[A-Z]*$/i;
	return ();
}
