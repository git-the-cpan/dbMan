package DBIx::dbMan::Extension::AutoSQL;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000030-000002"; }

sub preference { return 0; }

sub known_actions { return [ qw/AUTO_SQL/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'AUTO_SQL') {
		$obj->{-dbi}->be_quiet(1);
		my $current = $obj->{-dbi}->current;
		$obj->{-dbi}->set_current($action{connection});
		my $asql = $obj->{-dbi}->autosql();
		if (defined $asql) {
			$asql = [ $asql ] unless ref $asql;
			if (@$asql) {
				$obj->{-interface}->add_to_actionlist({ action => 'COMMAND', cmd => 'use %save' });
				$obj->{-interface}->add_to_actionlist({ action => 'COMMAND', cmd => "use $action{connection}" });
				for (@$asql) {
					$obj->{-interface}->add_to_actionlist({ action => 'COMMAND', cmd => $_ });
				}
				$obj->{-interface}->add_to_actionlist({ action => 'COMMAND', cmd => 'use %load' });
			}
		}
		$obj->{-dbi}->set_current($current);
		$obj->{-dbi}->be_quiet(0);
		$action{action} = 'NONE';
	}

	$action{processed} = 1;
	return %action;
}
