package DBIx::dbMan::Extension::Quit;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000003-000001"; }

sub preference { return 1000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND' 
		and $action{cmd} =~ /^(quit|exit|logout)/i) {
			$action{action} = 'QUIT';
	}

	$action{processed} = 1;
	return %action;
}
