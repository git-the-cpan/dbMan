package DBIx::dbMan::Extension::EditObjectsOracle;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;
use Text::FormatTable;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000045-000001"; }

sub preference { return 50; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'EDIT_OBJECT' and $obj->{-dbi}->driver eq 'Oracle') {
		unless ($obj->{-dbi}->current) {
			$action{action} = 'NONE';
			$obj->{-interface}->error("No current connection selected.");
			return %action;
		}
		my $d = $obj->{-dbi}->selectall_arrayref(q!
			SELECT object_name, object_type
			FROM user_objects
			WHERE UPPER(object_name) LIKE ? AND object_type !.($action{type}?(q! = '!.uc($action{type}).q!'!):q!IN ('PROCEDURE','FUNCTION','TRIGGER','VIEW','PACKAGE','PACKAGE BODY')!),
			{},uc($action{what}));
		if (defined $d) {
			$action{action} = 'NONE';
			if (@$d) {
				if (@$d == 1) {
					$action{action} = 'EDIT';
					$action{what} = $d->[0][0];
					$action{type} = $d->[0][1];
					delete $action{processed};
					return %action;
				} else {
					$action{action} = 'OUTPUT';
					$action{output} = "You must explicit say which object you want edit:\n";
					my $tab = new Text::FormatTable '| l | l |';
					$tab->rule;
					$tab->head('NAME','TYPE');
					$tab->rule;
					for (@$d) { $tab->row(@$_); }
					$tab->rule;
					$action{output} .= $tab->render($obj->{-interface}->render_size);
				}
			} else {
				$obj->{-interface}->error("Object ".$action{what}." not found.");
				return %action;
			}
		}
			
	}

	return %action;
}
