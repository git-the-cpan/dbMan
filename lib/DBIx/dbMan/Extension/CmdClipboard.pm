package DBIx::dbMan::Extension::CmdClipboard;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000064-000001"; }

sub preference { return 2000; }

sub known_actions { return [ qw/COMMAND/ ]; }

sub init {
        my $obj = shift;
        $obj->{prompt_num} = $obj->{-interface}->register_prompt(500);
}

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ s/^\\copy\s+//i) {
			$obj->{-mempool}->set('clipboard',{});
			$obj->{-interface}->prompt($obj->{prompt_num},'');
			$action{copy_to_clipboard} = 1;
			$action{clipboard_prompt_num} = $obj->{prompt_num};
			delete $action{processed};
		} elsif ($action{cmd} =~ /^\\clear$/i) {
			$obj->{-mempool}->set('clipboard',{});
			$obj->{-interface}->prompt($obj->{prompt_num},'');
			$action{action} = 'OUTPUT';
			$action{output} = "Clipboard cleared.\n";
		} elsif ($action{cmd} =~ /^\\paste(\s+(.*))?$/) {
			unless ($1) {
				$action{action} = 'OUTPUT';
				$action{output} = "You must specify insert-like command after \\paste.\n";
			} else {
				my $sql = $2;
				my $clip = $obj->{-mempool}->get('clipboard');
				if (exists $clip->{-result}) {
					for (@{$clip->{-result}}) {
                                		my $newaction = { action => 'SQL', sql => $sql, type => 'do', placeholders => $_ };
                                		$obj->{-interface}->add_to_actionlist($newaction);
					}
					$action{action} = 'OUTPUT';
					$action{output} = "Pasting from clipboard inserted into actionlist buffer.\n";
				} else {
					$action{action} = 'OUTPUT';
					$action{output} = "No data in clipboard.\n";
				}
			}
		} elsif ($action{cmd} =~ /^show\s+clipboard$/i) {
			my $clip = $obj->{-mempool}->get('clipboard');
			if (exists $clip->{-result}) {
				$action{action} = 'SQL_RESULT';
				$action{result} = $clip->{-result};
				$action{fieldnames} = $clip->{-fieldnames};
				$action{fieldtypes} = $clip->{-fieldtypes};
				$action{type} = 'select';
			} else {
				$action{action} = 'OUTPUT';
				$action{output} = "No data in clipboard.\n";
			}
			delete $action{processed};
		}
	}

	return %action;
}

sub cmdhelp {
	return [
		'\copy <command>' => 'Copy output of <command> to clipboard (<command> must be select-like command',
		'\paste <command>' => 'Paste block from clipboard into insert-like <command> with bind variables',
		'\clear' => 'Clear contents of clipboard',
		'SHOW CLIPBOARD' => 'Show contents of clipboard'
	];
}


sub restart_complete {
	my ($obj,$text,$line,$start) = @_;
	my %action = (action => 'LINE_COMPLETE', text => $text, line => $line,
		start => $start);
	do {
		%action = $obj->{-core}->handle_action(%action);
	} until ($action{processed});
	return @{$action{list}} if ref $action{list} eq 'ARRAY';
	return $action{list} if $action{list};
	return ();
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return $obj->restart_complete($text,$1,$start-(length($line)-length($1))) if $line =~ /^\s*\\(?:copy|paste)\s*\(.+?\)\s+(.*)$/i;
	return ('CLIPBOARD') if $line =~ /^\s*SHOW\s+/i;
	return ('\copy','\paste','SHOW','\clear') if $line =~ /^\s*$/i;
	return ('copy','paste','clear') if $line =~ /^\s*\\[A-Z]*$/i;
	return ();
}
