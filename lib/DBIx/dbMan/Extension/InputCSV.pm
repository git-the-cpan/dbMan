package DBIx::dbMan::Extension::InputCSV;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;
use Text::CSV_XS;
use FileHandle;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000041-000001"; }

sub preference { return 0; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'CSV_IN') {
		$action{action} = 'NONE';
		my $csv = new Text::CSV_XS { quote_char => $action{opt_quote},
			eol => $action{opt_eol},
			sep_char => $action{opt_separator} };

		my $file = new FileHandle "<$action{file}";
		unless (defined $file) {
			$obj->{-interface}->error("Can't load input CSV file $action{file}.");
			return %action;
		}
		local $/ = $action{opt_eol};
		my $now_head = 1;
		while (<$file>) {
			chomp;
			if ($csv->parse($_)) {
				my @f = $csv->fields();
				if ($now_head and $action{opt_headings} == 1) {
					$now_head = 0;  next;
				}
				$now_head = 0;
				my $newaction = { action => 'SQL', sql => $action{sql}, type => 'do', placeholders => \@f };
				$obj->{-interface}->add_to_actionlist($newaction);
			}
		}
		$file->close();
	}

	$action{processed} = 1;
	return %action;
}
