package DBIx::dbMan::Interface;

use strict;
use vars qw/$VERSION/;

$VERSION = '0.01';

1;

sub new {
	my $class = shift;
	my $obj = bless { @_ }, $class;
	$obj->init();
	return $obj;
}

sub init {
	my $obj = shift;

}

sub print {
	my $obj = shift;
	print $obj->{-lang}->str(@_);
}

sub hello {
	my $obj = shift;
	$obj->print("This is dbMan, Version $VERSION.\n");
}

sub goodbye {
	my $obj = shift;
	$obj->print("Bye.\n");
}

sub get_action {
	my $obj = shift;
	my %action = qw/action NONE/;

	$obj->prompt;
	my $command = $obj->get_command();

	if ($command) {
		$action{action} = 'COMMAND';
		$action{cmd} = $command;
	}

	return %action;
}

sub prompt {
	my $obj = shift;

	$obj->print("SQL: ");
}

sub get_command {
	my $obj = shift;
	my $command = <>;
	return $command;
}

