package DBIx::dbMan::Extension::Clipboard;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000065-000001"; }

sub preference { return 80; }

sub known_actions { return [ qw/SQL_RESULT/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'SQL_RESULT' and $action{copy_to_clipboard} and ref $action{result} eq 'ARRAY') {
		delete $action{copy_to_clipboard};
		$obj->{-mempool}->set('clipboard',{ -result => $action{result}, -fieldnames => $action{fieldnames}, -fieldtypes => $action{fieldtypes}});
		delete $action{processed};
		$action{output_info} = "Copy to clipboard done.\n";
		$obj->{-interface}->prompt($action{clipboard_prompt_num},'[clip]');
	}

	return %action;
}
