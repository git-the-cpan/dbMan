package DBIx::dbMan::Extension::SQLOutputTable;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;
use Text::FormatTable;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000026-000001"; }

sub preference { return -25; }

sub init {
	my $obj = shift;
	$obj->{-mempool}->register('output_format','table');
	$obj->{-mempool}->set('output_format','table') unless $obj->{-mempool}->get('output_format');
}

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'SQL_OUTPUT') {	# table is standard fallback
		# $action{fieldtypes} - formatting ?
		my $table = new Text::FormatTable ('|'.( 'l|' x scalar @{$action{fieldnames}} ));
		$table->rule;
		$table->head(@{$action{fieldnames}});
		$table->rule;
		for (@{$action{result}}) {
			$table->row(@$_);
		}
		$table->rule;
		$action{action} = 'OUTPUT';
		$action{output} = $table->render($obj->{-interface}->render_size);
		delete $action{processed};
	}

	return %action;
}
