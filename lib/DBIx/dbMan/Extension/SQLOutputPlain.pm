package DBIx::dbMan::Extension::SQLOutputPlain;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000027-000001"; }

sub preference { return 0; }

sub init {
	my $obj = shift;
	$obj->{-mempool}->register('output_format','plain');
}

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'SQL_OUTPUT') {
		if ($obj->{-mempool}->get('output_format') eq 'plain') {
			my $output = join ',',@{$action{fieldnames}};
			$output .= "\n";
			for (@{$action{result}}) {
				$output .= join ',',map { /^\d+$/ ? $_ : '"'.$_.'"' } @$_;
				$output .= "\n";
			}
			$action{action} = 'OUTPUT';
			$action{output} = $output;
			delete $action{processed};
		}
	}

	return %action;
}
