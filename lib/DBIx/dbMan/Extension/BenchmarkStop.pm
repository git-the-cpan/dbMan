package DBIx::dbMan::Extension::BenchmarkStop;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000052-000001"; }

sub preference { return -40; }

sub init {
	my $obj = shift;

	$obj->{hires} = 0;
	eval q{
		use Time::HiRes qw/gettimeofday tv_interval/;
	};
	++$obj->{hires} unless $@;
}

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{benchmark_starttime}) {
		my $time;
		if ($obj->{hires}) {
			eval q{
				$time = tv_interval($action{benchmark_starttime},[ gettimeofday ]);
			};
		} else {
			$time = time-$action{benchmark_starttime};
		}
		delete $action{benchmark_starttime};
		my $info = "Elapsed time: $time s\n";
		if ($action{action} eq 'OUTPUT') {
			$action{output} .= $info;
		} else {
			$obj->{-interface}->print($info);
		}
	}

	$action{processed} = 1;
	return %action;
}
