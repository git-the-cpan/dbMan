package DBIx::dbMan::Extension::BenchmarkStart;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000051-000001"; }

sub preference { return 99999; }

sub init {
	my $obj = shift;

	$obj->{hires} = 0;
	eval q{
		use Time::HiRes gettimeofday;
	};
	++$obj->{hires} unless $@;
}

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND' and 
	  $obj->{-mempool}->get('benchmark') and
	  not $action{benchmark_starttime}) {
		if ($obj->{hires}) {
			eval q{
				$action{benchmark_starttime} = [ gettimeofday ];
			};
		} else {
			$action{benchmark_starttime} = time;
		}
	}

	$action{processed} = 1;
	return %action;
}
