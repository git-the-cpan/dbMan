package DBIx::dbMan::Extension::StandardSQL;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.03';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000014-000003"; }

sub preference { return 100; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'SQL') {
		if ($action{oper} eq 'complete') {
			$action{action} = 'NONE';
			if ($action{what} eq 'list') {
				# return in {list} list of {type}
				my $sth = $obj->{-dbi}->table_info();
				my $ret = $sth->fetchall_arrayref();
				my @all = ();
				if (defined $ret) {
					if ($action{type} eq 'object' or
						  $action{type} eq lc $_->[3]) {
						push @all,$_->[2];
					}
				}
				$sth->finish;
				$action{list} = \@all;
			}
		} elsif ($action{type} eq 'select' or $action{type} eq 'do') {
			$action{action} = 'NONE';
			unless ($obj->{-dbi}->current) {
				$obj->{-interface}->error("No current connection selected.");
				return %action;
			}
			
			my $explain_id = $$;
			if ($action{explain} and not $action{explain_2phase}) {
				$action{sql_save} = $action{sql};
				$action{sql} = qq!DELETE FROM plan_table WHERE statement_id = '$explain_id'!;
				$action{explain_2phase} = 1;
			} else {
				$action{sql} =~ s/explain\s+plan\s+for/explain plan set statement_id = '$explain_id' for/;
				delete $action{explain_2phase};
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
				if ($action{type} eq 'select' and not $action{explain}) {
					$res = $sth->fetchall_arrayref();
					$action{fieldnames} = $sth->{NAME_uc};
					$action{fieldtypes} = $sth->{TYPE};
				}
				if ($action{explain}) {
					$action{action} = 'SQL';
					if ($action{explain_2phase}) {
						$action{sql} = $action{sql_save};
						$sth->finish;
						delete $action{processed};
						return %action;
					}
					$action{sql} = q!SELECT '.' || LPAD(' ',2*LEVEL-1) || operation || ' ' || options || ' ' || object_name "Execution Plan" FROM plan_table WHERE statement_id = '!.$explain_id.q!' CONNECT BY PRIOR id = parent_id AND statement_id = '!.$explain_id.q!' START WITH id = 0!;
					delete $action{explain};
				} else {
					$action{action} = 'SQL_RESULT';
					$action{result} = $res;
				}
			}
			$sth->finish;
			delete $action{processed};
		}
	}

	return %action;
}
