package DBIx::dbMan::Extension::SQLOutputOldTable;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;
use Data::ShowTable;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000053-000002"; }

sub preference { return 0; }

sub known_actions { return [ qw/SQL_OUTPUT/ ]; }

sub init {
	my $obj = shift;
	$obj->{-mempool}->register('output_format','oldtable');
	$obj->{-mempool}->register('output_format','sqlplus');
	$obj->{-mempool}->register('output_format','records');
}

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'SQL_OUTPUT') {
		if ($obj->{-mempool}->get('output_format') =~ /^(oldtable|sqlplus|records)$/) {
			my @widths = ();
			for ($action{fieldnames},@{$action{result}}) {
				my $i = 0;
				for (@$_) {
					$widths[$i] = length($_) if $widths[$i] < length($_);
					++$i;
				}
			}
			my $i = 0;
			my $table = '';
			open F,">/tmp/dbman.$$.showtable";
			*OLD = *STDOUT;
			*STDOUT = *F;
			if ($obj->{-mempool}->get('output_format') eq 'sqlplus') {
				ShowSimpleTable({
					titles => $action{fieldnames},
					types => [ map { 'text' } @{$action{fieldnames}} ],
					widths => \@widths,
					row_sub => sub { 
						if (shift) { $i = 0;  return 1; }
						return () unless defined $action{result}->[$i];
						return @{$action{result}->[$i++]};
					}});
			} elsif ($obj->{-mempool}->get('output_format') eq 'records') {
				ShowListTable({
					titles => $action{fieldnames},
					types => [ map { 'text' } @{$action{fieldnames}} ],
					widths => \@widths,
					row_sub => sub { 
						if (shift) { $i = 0;  return 1; }
						return () unless defined $action{result}->[$i];
						return @{$action{result}->[$i++]};
					}});
			} else {
				ShowBoxTable({
					titles => $action{fieldnames},
					types => [ map { 'text' } @{$action{fieldnames}} ],
					widths => \@widths,
					row_sub => sub { 
						if (shift) { $i = 0;  return 1; }
						return () unless defined $action{result}->[$i];
						return @{$action{result}->[$i++]};
					}});
			};
			*STDOUT = *OLD;
			close F;
			if (open F,"/tmp/dbman.$$.showtable") {
				$table = join '',<F>;
				close F;
			}
			unlink "/tmp/dbman.$$.showtable" if -f "/tmp/dbman.$$.showtable";
			$action{action} = 'OUTPUT';
			$action{output} = $table;
			delete $action{processed};
		}
	}

	return %action;
}
