package DBIx::dbMan::Extension::CmdConnections;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000004-000001"; }

sub preference { return 2000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^open\s+(\S*)$/i) {
			$action{action} = 'CONNECTION';
			$action{operation} = 'open';
			$action{what} = $1;
		} elsif ($action{cmd} =~ /^close\s+(\S*)$/i) {
			$action{action} = 'CONNECTION';
			$action{operation} = 'close';
			$action{what} = $1;
		} elsif ($action{cmd} =~ /^use(?:\s+(\S*))?$/i) {
			$action{action} = 'CONNECTION';
			$action{operation} = 'use';
			if ($1 eq '%save') {
				$obj->{-mempool}->set('connection_saved',$obj->{-dbi}->current);
				$action{action} = 'NONE';
			} elsif ($1 eq '%load') {
				$action{what} = $obj->{-mempool}->get('connection_saved');
			} else {
				$action{what} = $1;
			}
		} elsif ($action{cmd} =~ /^show\s+(active|all)?\s*connections?$/i) {
			$action{action} = 'CONNECTION';
			$action{operation} = 'show';
			if (lc $1 eq 'active') {
				$action{what} = 'active';
			} else {
				$action{what} = 'all';
			}
		} elsif ($action{cmd} =~ /^create\s+(permanent\s+)?connection\s+(\S+)\s+as\s+(\S+?):(.*?)\s+login\s+(\S+)(?:\s+(password\s+(\S+)|nopassword))?(\s+autoopen)?$/i) {
			# as driver:dsn login user [password password]
			$action{action} = 'CONNECTION';
			$action{operation} = 'create';
			$action{permanent} = 'yes' if $1;
			$action{what} = $2;
			$action{driver} = $3;
			$action{dsn} = $4;
			$action{login} = $5;
			if (lc $6 eq 'nopassword') {
				$action{password} = '';
			} else {
				$action{password} = $7;
				unless ($action{password}) {
					$action{password} = $obj->{-interface}->get_password('Password: ');
				}
			}
			$action{auto_login} = 'yes' if $8;
		} elsif ($action{cmd} =~ /^drop\s+(permanent\s+)?connection\s+(\S+)$/i) {
			$action{action} = 'CONNECTION';
			$action{operation} = 'drop';
			$action{permanent} = 'yes' if $1;
			$action{what} = $2;
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'OPEN <connection_name>' => 'Open specific connection',
		'CLOSE <connection_name>' => 'Close specific connection',
		'USE <connection_name>' => 'Set selected connecection as current',
		'SHOW [ACTIVE|ALL] CONNECTIONS' => 'Show list of active/all connections',
		'CREATE [PERMANENT] CONNECTION <name> AS <driver>:<dsn> LOGIN <login> [PASSWORD <password> | NOPASSWORD] [AUTOOPEN]' => 'Creating new connection',
		'DROP [PERMANENT] CONNECTION <name>' => 'Droping specific connection'
		];
}
