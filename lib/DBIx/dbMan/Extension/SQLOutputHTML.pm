package DBIx::dbMan::Extension::SQLOutputHTML;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000028-000002"; }

sub preference { return 0; }

sub init {
	my $obj = shift;
	$obj->{-mempool}->register('output_format','html');
}

sub known_actions { return [ qw/SQL_OUTPUT/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'SQL_OUTPUT') {
		if ($obj->{-mempool}->get('output_format') eq 'html') {
			my $output = "<TABLE>\n<TR>";
			$output .= join '',map { "<TH>$_</TH>" } @{$action{fieldnames}};
			$output .= "</TR>\n";
			for (@{$action{result}}) {
				$output .= "<TR>".(join '',map { "<TD>$_</TD>" } @$_);
				$output .= "</TR>\n";
			}
			$output .= "</TABLE>\n";
			$action{action} = 'OUTPUT';
			$action{output} = $output;
			delete $action{processed};
		}
	}

	return %action;
}
