package DBIx::dbMan::Extension::ShowTablesOracle;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;
use Text::FormatTable;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000039-000001"; }

sub preference { return 50; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'SHOW_TABLES' and $obj->{-dbi}->driver eq 'Oracle') {
		my $table = new Text::FormatTable '| l | l |';
		$table->rule;
		$table->head('NAME','TYPE');
		$table->rule;

		my $sth = $obj->{-dbi}->table_info( { TABLE_SCHEM => uc($obj->{-dbi}->login) } );
		my $ret = $sth->fetchall_arrayref();
		if (defined $ret) {
			for (sort { $a->[2] cmp $b->[2] } @$ret) {
				$table->row($_->[2],$_->[3]);
			}
		}
		$sth->finish;
		$table->rule;
		$action{action} = 'OUTPUT';
		$action{output} = $table->render($obj->{-interface}->render_size);
	}

	$action{processed} = 1;
	return %action;
}
