package DBIx::dbMan::Extension::History;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;
use Text::FormatTable;
use DBIx::dbMan::History;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000035-000001"; }

sub preference { return 0; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'HISTORY') {
		if ($action{operation} eq 'show') {
			my $table = new Text::FormatTable '| r l |';
			$table->rule;
			my $i = 1;
			my $history = new DBIx::dbMan::History -config => $obj->{-config};
			for ($history->load()) {	
				$table->row("$i.",$_);
				++$i;
			}
			$table->rule;
			$action{action} = 'OUTPUT';
			$action{output} = $table->render($obj->{-interface}->render_size);
		} elsif ($action{operation} eq 'clear') {
			my $history = new DBIx::dbMan::History -config => $obj->{-config};
			$history->clear();
			$action{action} = 'OUTPUT';
			$action{output} = "Commands history cleared.\n";
		}
	}

	$action{processed} = 1;
	return %action;
}