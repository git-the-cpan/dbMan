package DBIx::dbMan::Extension::CmdDescribe;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000031-000001"; }

sub preference { return 1200; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^(?:describe|\\d)\s+(.*)$/i) {
			$action{action} = 'DESCRIBE';
			$action{what} = $1;
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'DESCRIBE <table>' => 'Describe structure of <table>'
	];
}

