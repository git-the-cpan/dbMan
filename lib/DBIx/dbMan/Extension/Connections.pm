package DBIx::dbMan::Extension::Connections;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;
use Text::FormatTable;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000005-000001"; }

sub preference { return 0; }

sub init {
	my $obj = shift;
	$obj->{prompt_num} = $obj->{-interface}->register_prompt;
}

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'CONNECTION') {
		if ($action{operation} eq 'open') {
			$obj->{-dbi}->open($action{what});
			$action{action} = 'NONE';
		} elsif ($action{operation} eq 'close') {
			$obj->{-dbi}->close($action{what});
			$action{action} = 'NONE';
		} elsif ($action{operation} eq 'use') {
			$obj->{-dbi}->set_current($action{what});
			$action{action} = 'NONE';
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
			for (qw/driver dsn login password auto_login/) {
				$parm{$_} = $action{$_};
			}
			$obj->{-dbi}->create_connection($action{what},\%parm);
			$obj->{-dbi}->save_connection($action{what}) if $action{permanent};
			$action{action} = 'NONE';
		} elsif ($action{operation} eq 'drop') {
			$obj->{-dbi}->drop_connection($action{what});
			$obj->{-dbi}->destroy_connection($action{what}) if $action{permanent};
			$action{action} = 'NONE';
		}

		my $db = '';
		$db = '<'.$obj->{-dbi}->current.'>' if $obj->{-dbi}->current;
		$obj->{-interface}->prompt($obj->{prompt_num},$db);
	}

	$action{processed} = 1;
	return %action;
}

