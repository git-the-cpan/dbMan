package DBIx::dbMan::Extension::Clipboard;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.02';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000065-000002"; }

sub preference { return 80; }

sub known_actions { return [ qw/SQL_RESULT/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'SQL_RESULT' and $action{copy_to_clipboard} and ref $action{result} eq 'ARRAY') {
		delete $action{copy_to_clipboard};
		if ($action{union_clipboard}) {
			my $clip = $obj->{-mempool}->get('clipboard');
			if (exists $clip->{-result}) {
				if (scalar @{$action{result}->[0]} != scalar @{$clip->{-result}->[0]}) {
					$action{output_info} = "Cannot union copy results with different number of columns.\n";
				} else { 
					$clip->{-result} = [ @{$clip->{-result}}, @{$action{result}} ];
					$obj->{-mempool}->set('clipboard',$clip);
					$action{output_info} = "Union copy to clipboard done.\n";
				}
			} else {
				delete $action{union_clipboard};
			}
		} 
		unless ($action{union_clipboard}) {
			$obj->{-mempool}->set('clipboard',{ -result => $action{result}, -fieldnames => $action{fieldnames}, -fieldtypes => $action{fieldtypes}});
			$action{output_info} = "Copy to clipboard done.\n";
		}
		delete $action{processed};
		$obj->{-interface}->prompt($action{clipboard_prompt_num},'[clip]');
	}

	return %action;
}
