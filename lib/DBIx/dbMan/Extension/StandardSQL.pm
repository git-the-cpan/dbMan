package DBIx::dbMan::Extension::StandardSQL;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000014-000002"; }

sub preference { return 50; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'SQL') {
		if ($action{type} eq 'select' or $action{type} eq 'do') {
			$action{action} = 'NONE';
			unless ($obj->{-dbi}->current) {
				$obj->{-interface}->error("No current connection selected.");
				return %action;
			}
			
			my $sth = $obj->{-dbi}->prepare($action{sql});
			if (exists $action{placeholders}) {
				my $i = 0;
				for (@{$action{placeholders}}) {
					$sth->bind_param(++$i,$_);
				}
			}
			unless (defined $sth) {
				$action{action} = 'OUTPUT';
				$action{output} = $obj->{-dbi}->errstr()."\n";
				$action{processed} = 1;
				return %action;
			}
			my $res = $sth->execute();
			if (not defined $res) {
				my $errstr = $obj->{-dbi}->errstr();
				$errstr =~ s/^ERROR:\s*//;
				$obj->{-interface}->error($errstr);
			} else {
				if ($action{type} eq 'select') {
					$res = $sth->fetchall_arrayref();
					$action{fieldnames} = $sth->{NAME_uc};
					$action{fieldtypes} = $sth->{TYPE};
				}
				$action{action} = 'SQL_RESULT';
				$action{result} = $res;
			}
			$sth->finish;
			delete $action{processed};
		}
	}

	return %action;
}
