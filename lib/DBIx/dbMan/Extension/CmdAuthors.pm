package DBIx::dbMan::Extension::CmdAuthors;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000011-000001"; }

sub preference { return 1000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^authors$/i) {
			$action{action} = 'AUTHORS';
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'AUTHORS' => 'Show all authors (program, extensions)'
	];
}
