package DBIx::dbMan::Extension::Connections;

use strict;
use base 'DBIx::dbMan::Extension';
use Text::FormatTable;
use DBI;

our $VERSION = '0.06';

1;

sub IDENTIFICATION { return "000001-000005-000006"; }

sub preference { return 0; }

sub known_actions { return [ qw/CONNECTION/ ]; }

sub init {
	my $obj = shift;
	$obj->{prompt_num} = $obj->{-interface}->register_prompt;
}

sub done {
	my $obj = shift;
	$obj->{-interface}->deregister_prompt($obj->{-prompt_num});
}

sub solve_open_error {
	my ($obj,$error,$name) = @_;

	if ($error == -1) {
		return "Can't find driver for ".$obj->{connections}->{$name}->{driver}.".\n";
	} elsif ($error == -2) {
		return "Can't connect to $name (reason: ".DBI->errstr.").\n";
	} elsif ($error == -3) {
		return "Unknown connection $name.\n";
	} elsif ($error == -4) {
		return "Already connected to $name.\n";
	} elsif (not $error) {
	        return "Connection to $name established.\n";
	}
}

sub solve_close_error {
	my ($obj,$error,$name) = @_;

	if ($error == -1) {
		return "Unknown connection $name.\n";
	} elsif ($error == -2) {
		return "Not connected to $name.\n";
	} elsif (not $error) {
	        return "Disconnected from $name.\n";
	}
}

sub solve_use_error {
	my ($obj,$error,$name) = @_;

	if ($error == 1) {
		return "Unset current connection.\n";
	} elsif ($error == -1) {
		return "Unknown connection $name.\n";
	} elsif ($error == -2) {
		return "Not connected to $name.\n";
	} elsif (not $error) {
		return "Set current connection to $name.\n";
	}
}

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'CONNECTION') {
		if ($action{operation} eq 'open') {
			my $error = $obj->{-dbi}->open($action{what});
			$action{action} = 'OUTPUT';
			$action{output} = $obj->solve_open_error($error,$action{what});
		} elsif ($action{operation} eq 'reopen') {
			my $reuse = 0;
			$reuse = 1 if $obj->{-dbi}->current eq $action{what};

			$action{action} = 'OUTPUT';
			my $error = $obj->{-dbi}->close($action{what});
			$action{output} = $obj->solve_close_error($error,$action{what});

			$error = $obj->{-dbi}->open($action{what});
			$action{output} .= $obj->solve_open_error($error,$action{what});

			if ($reuse) {
				$error = $obj->{-dbi}->set_current($action{what});
				$action{output} .= $obj->solve_use_error($error,$action{what});
			}
		} elsif ($action{operation} eq 'close') {
			$action{action} = 'OUTPUT';
			my $error = $obj->{-dbi}->close($action{what});
			$action{output} = $obj->solve_close_error($error,$action{what});
		} elsif ($action{operation} eq 'use') {
			$action{action} = 'OUTPUT';
			my $error = $obj->{-dbi}->set_current($action{what});
			$action{output} = $obj->solve_use_error($error,$action{what});
		} elsif ($action{operation} eq 'show') {
			my @list = @{$obj->{-dbi}->list($action{what})};
			my $clist = '';
			if (@list) {
				$clist .= ($action{what} eq 'active'?'Active c':'C')."onnections:\n";
				my $table = new Text::FormatTable '| l l | l | l | l | l | l |';
				$table->rule;
				$table->head('C','NAME','ACTIVE','PERMANENT','DRIVER','LOGIN','DSN');
				$table->rule;
				for (@list) {
					$table->row((($obj->{-dbi}->current eq $_->{name})?'*':' '),$_->{name},($_->{-logged}?'yes':'no'),($obj->{-dbi}->is_permanent_connection($_->{name})?'yes':'no'),$_->{driver},$_->{login},$_->{dsn});
				}
				$table->rule;
				$clist .= $table->render($obj->{-interface}->render_size);
			} else {
				$action{what} = '' if $action{what} ne 'active';
				$clist .= "No".($action{what}?' '.$action{what}:'')." connection.\n";
			}
			$action{action} = 'OUTPUT';
			$action{output} = $clist;
		} elsif ($action{operation} eq 'create') {
			my %parm = ();
			for (qw/driver dsn login password auto_login/) { $parm{$_} = $action{$_}; }

			$action{action} = 'NONE';
			my $error = $obj->{-dbi}->create_connection($action{what},\%parm);
			if ($error == -1) {
				$action{action} = 'OUTPUT';
				$action{output} = "Connection with name $action{what} already exists.\n";
			} elsif ($error >= 0) {
				$action{action} = 'OUTPUT';
				$action{output} = "Connection $action{what} created.\n";
				if ($error > 50) {
					$action{output} .= $obj->solve_open_error($error-100,$action{what}) if $error > 50;
				}
				if ($action{permanent}) {
					$error = $obj->{-dbi}->save_connection($action{what});
					if ($error == -1) {
						$action{output} .= "Connection with name $action{what} not exists.\n";
					} elsif (not $error) {
						$action{output} .= "Making connection $action{what} permanent.\n";

					}
				}
			}
		} elsif ($action{operation} eq 'drop') {
			$action{action} = 'NONE';
			my $error = $obj->{-dbi}->drop_connection($action{what});
			if ($error == -1) {
				$action{action} = 'OUTPUT';
				$action{output} = "Connection with name $action{what} not exists.\n";
			} elsif (not $error) {
				$action{action} = 'OUTPUT';
				$action{output} = "Connection $action{what} dropped.\n";
				if ($action{permanent}) {
					$error = $obj->{-dbi}->destroy_connection($action{what});
					if ($error == -2) {
						$action{output} .= "Can't destroy connection $action{what}.\n";
					} elsif (not $error) {
						$action{output} .= "Destroying permanent connection $action{what}.\n";

					}
				}
			}
		}

		my $db = '';
		$db = '<'.$obj->{-dbi}->current.'>' if $obj->{-dbi}->current;
		$obj->{-interface}->prompt($obj->{prompt_num},$db);
	}

	$action{processed} = 1;
	return %action;
}

