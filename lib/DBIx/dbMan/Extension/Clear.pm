package DBIx::dbMan::Extension::Clear;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000057-000002"; }

sub preference { return 0; }

sub known_actions { return [ qw/SCREEN/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'SCREEN') {
		if ($action{operation} eq 'clear') {
			my $oldpath = $ENV{PATH};
			$ENV{PATH} = '';
			system '/usr/bin/clear';
			$ENV{PATH} = $oldpath;
			$action{action} = 'NONE';
		}
	}

	$action{processed} = 1;
	return %action;
}
