package DBIx::dbMan::Extension::CmdInputFile;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000023-000002"; }

sub preference { return 1000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^(?:\\i\s+|\@)(.*)$/i) {
			$action{action} = 'INPUT_FILE';
			$action{file} = $1;
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'\i <file>' => 'Input commands from <file>'
	];
}

