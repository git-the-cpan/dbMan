package DBIx::dbMan::Extension::CmdStandardSQL;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.05';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000013-000005"; }

sub preference { return 1000; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'COMMAND') {
		if ($action{cmd} =~ /^(select|explain)\s+/i) {
			$action{action} = 'SQL';
			$action{type} = 'select';
			$action{sql} = $action{cmd};
			$action{explain} = 1 if $action{cmd} =~ /^explain\s+/i;
		} elsif ($action{cmd} =~ /^((delete|insert|update|create|drop|begin|alter|truncate|grant|revoke|analyze)\s+.*|vacuum)$/i) {
			$action{action} = 'SQL';
			$action{type} = 'do';
			$action{sql} = $action{cmd};
		}
	}

	$action{processed} = 1;
	return %action;
}

sub objectlist {
	my ($obj,$type,$text) = @_;
	my %action = (action => 'SQL', oper => 'complete', what => 'list', type => $type, context => $text);
	do {
		%action = $obj->{-core}->handle_action(%action);
	} until ($action{processed});
	return @{$action{list}} if ref $action{list} eq 'ARRAY';
	return ();
}

sub cmdcomplete {
	my ($obj,$text,$line,$start) = @_;
	return () unless $obj->{-dbi}->current;
	return ('(',qw/VALUES SELECT/) if $line =~ /^\s*INSERT\s+INTO\s+(\S+)\s+$/i;
	return qw/VALUES SELECT/ if $line =~ /^\s*INSERT\s+INTO\s+(\S+)\s+(\([^)]+\))?\s*[A-Z]*$/i;
	return ('(') if $line =~ /^\s*INSERT\s+INTO\s+(\S+)\s+(\([^)]+\)\s*)?VALUES\s*$/i;
	return ($obj->objectlist('FUNCTION',$text),$obj->objectlist('SEQ',$text)) if $line =~ /^\s*INSERT\s+INTO\s+(\S+)\s+(\([^)]+\))?\s*VALUES/i;
	return ($obj->objectlist('CONTEXT',$text),$obj->objectlist('SEQ',$text)) if $line =~ /^\s*INSERT\s+INTO\s+(\S+)\s+(\([^)]+\))?\s*SELECT/i;
	return ($obj->objectlist('FIELDS',$1.'.')) if $line =~ /^\s*INSERT\s+INTO\s+(\S+)\s+/i;
	return qw/SELECT/ if $line =~ /^\s*EXPLAIN\s+PLAN\s+FOR\s+\S*$/i;
	return qw/FOR/ if $line =~ /^\s*EXPLAIN\s+PLAN\s+\S*$/i;
	return qw/PLAN/ if $line =~ /^\s*EXPLAIN\s+\S*$/i;
	return $obj->objectlist($1) if $line =~ /^\s*DROP\s+(PACKAGE\s+BODY|\S+)\s+\S*$/i;
	return qw/WHERE/ if $line =~ /^\s*DELETE\s+FROM\s+\S+\s+\S*$/i;
	return qw/STATISTICS/ if $line =~ /^\s*ANALYZE\s+TABLE\s+\S+\s+(COMPUTE|ESTIMATE|DELETE)\s+\S*$/i;
	return ('COMPUTE STATISTICS','ESTIMATE STATISTICS','DELETE STATISTICS') if $line =~ /^\s*ANALYZE\s+TABLE\s+\S+\s+\S*$/i;
	return qw/SET/ if $line =~ /^\s*UPDATE\s+\S+\s+\S*$/i;
	return $obj->objectlist('TABLE') if $line =~ /^\s*(TRUNCATE\s+TABLE|DELETE\s+FROM|INSERT\s+INTO|UPDATE|ALTER\s+TABLE|ANALYZE\s+TABLE)\s+\S*$/i;
	return qw/TABLE/ if $line =~ /^\s*TRUNCATE\s+\S*$/i;
	return qw/FROM/ if $line =~ /^\s*DELETE\s+\S*$/i;
	return qw/INTO/ if $line =~ /^\s*INSERT\s+\S*$/i;
	return qw/TABLE INDEX CLUSTER/ if $line =~ /^\s*ANALYZE\s+\S*$/i;
	return ('BODY',$obj->objectlist('PACKAGE')) if $line =~ /^\s*DROP\s+PACKAGE\s+\S*$/i;
	return qw/TABLE SEQUENCE VIEW FUNCTION PACKAGE PROCEDURE TRIGGER/ if $line =~ /^\s*(DROP|CREATE|ALTER)\s+\S*$/i;
	return qw/SELECT EXPLAIN DELETE INSERT UPDATE CREATE DROP BEGIN ALTER TRUNCATE GRANT REVOKE ANALYZE/ if $line =~ /^\s*[A-Z]*$/i;
	return ($obj->objectlist('CONTEXT',$text),$obj->objectlist('SEQ',$text)) if $line =~ /^\s*(SELECT|DELETE|UPDATE|EXPLAIN)\s+/i;
}

sub cmdhelp {
	return [
		'EXPLAIN PLAN FOR <select>' => 'Explain (Oracle) plan for executing query <select>'
	];

}
