package DBIx::dbMan::Extension::CmdFormat;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000062-000001"; }

sub preference { return 2000; }

sub known_actions { return [ qw/COMMAND/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ s/^\\f\s*\((.*?)\)\s+//i) {
			$action{old_output_format} = $obj->{-mempool}->get('output_format');
			my $want = lc $1;
			$want =~ s/^\s+//;
			my @fmts = $obj->{-mempool}->get_register('output_format');
			my %fmts = ();  for (@fmts) { ++$fmts{$_}; }
                        if ($fmts{$want}) {
                                $obj->{-mempool}->set('output_format',$want);
				delete $action{processed};
                        } else {
				$action{action} = 'OUTPUT';
				$action{output} = "Unknown output format.\n".
					"Registered formats: ".(join ',',sort @fmts)."\n";
			}
		}
	}

	return %action;
}

sub cmdhelp {
	return [
		'\f(<format>) <command>' => 'Format output of <command> as <format>'
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

sub formatlist {
        my $obj = shift;
        return $obj->{-mempool}->get_register('output_format');
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return $obj->restart_complete($text,$1,$start-(length($line)-length($1))) if $line =~ /^\s*\\f\s*\(.+?\)\s+(.*)$/i;
	return $obj->formatlist if $line =~ /^\s*\\f\s*\(\s*\S*$/i;
	return ('\f') if $line =~ /^\s*$/i;
	return ('f(') if $line =~ /^\s*\\[A-Z]*$/i;
	return ();
}
