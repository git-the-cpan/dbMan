package DBIx::dbMan::Extension::InputFile;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000024-000001"; }

sub preference { return 0; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'INPUT_FILE') {
		$action{action} = 'NONE';
		unless (open F,$action{file}) {
			$obj->{-interface}->error("Can't load input file $action{file}.");
			return %action;
		}
		while (<F>) {
			chomp;
			my $newaction = { action => 'COMMAND', cmd => $_ };
			$obj->{-interface}->add_to_actionlist($newaction);
		}
		close F;
	}

	$action{processed} = 1;
	return %action;
}
