package DBIx::dbMan::Extension::SQLResultPreprocess;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.03';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000054-000003"; }

sub preference { return 50; }

sub known_actions { return [ qw/SQL_RESULT/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'SQL_RESULT' and not $action{sql_result_preprocess} and ref $action{result} eq 'ARRAY') {
		for (@{$action{result}}) {
			for my $string (@$_) {
				next unless defined $string;
				my @string = unpack "C*", $string;
				$string = '';
				for (@string) {
					if ($_ >= 32 && $_ <= 254 && $_ != 127) {
						$string .= chr($_);
					} else {
						$string .= sprintf "<%02x>",$_;
					}
				}
			}
		}

		$action{sql_result_preprocess} = 1;
		delete $action{processed};
	}

	return %action;
}
