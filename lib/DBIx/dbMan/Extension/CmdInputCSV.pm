package DBIx::dbMan::Extension::CmdInputCSV;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000040-000001"; }

sub preference { return 1500; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^\\csvin(?:\[(.*)\])?\((.*?)\)\s+(.*)$/i) {
			$action{action} = 'CSV_IN';
			$action{file} = $2;
			$action{sql} = $3;
			$action{opt_separator} = ',';
			$action{opt_quote} = '"';
			$action{opt_eol} = "\n";
			$action{opt_headings} = 0;
			my $opt = $1;
			my @opts = split /\s+/,$opt;
			for (@opts) {
				my ($tag,$value) = split /=/,$_;
				$value =~ s/\\s/ /g;
				
				$value =~ s/\\(.)/my $v=''; my $src='$v="\\'.$1.'";'; eval $src; $v/eg;

				if ($tag =~ /^(separator|quote|eol|headings)$/) {
					$action{"opt_$tag"} = $value;
				} else {
					$action{action} = 'NONE';
					$obj->{-interface}->error('Unknown option in \csvin');
				}
			}
		}
	}

	$action{processed} = 1;
	return %action;
}

sub cmdhelp {
	return [
		'\csvin[<options>](<file>) <command>' => 'Import CSV file <file> through placeholders in <command> (with optionable <options> defined like separator=, quote=" eol=\n headings=0 where headings=0 is no headings, =1 is headings skip, \s means space, \t means tabulator)'
	];
}

