package DBIx::dbMan::Interface;

use strict;
use vars qw/$VERSION/;

$VERSION = '0.05';

1;

sub new {
	my $class = shift;
	my $obj = bless { @_ }, $class;
	$obj->{prompt_num} = 0;
	$obj->{actionlist} = [];
	$obj->init();
	return $obj;
}

sub init {
	my $obj = shift;
	$obj->prompt($obj->register_prompt(99999999),'SQL:');
}

sub print {
	my $obj = shift;
	print $obj->{-lang}->str(@_);
}

sub hello {
	my $obj = shift;
	$obj->print("This is dbMan, Version $main::DBIx::dbMan::VERSION.\n\n");
}

sub goodbye {
	my $obj = shift;
	$obj->print("Bye.\n");
}

sub get_action {
	my $obj = shift;
	my %action = qw/action NONE/;

	if (@{$obj->{actionlist}}) {
		my $action = shift @{$obj->{actionlist}};
		%action = %$action;
	} else {
		my $command = $obj->get_command();
		$command =~ s/\n+$//;

		if ($command) {
			$action{action} = 'COMMAND';
			$action{flags} = 'real';
			$action{cmd} = $command;
		} else {
			$action{action} = 'IDLE';
		}
	}

	return %action;
}

sub prompt {
	my ($obj,$num,$prompt) = @_;

	$obj->{prompt}->[$num] = $prompt;
}

sub get_prompt {
	my $obj = shift;

	my $prompt = '';
	for (sort { 
			($obj->{prompt_priority_list}->[$a] == $obj->{prompt_priority_list}->[$b])
			? ($b <=> $a)
			: ($obj->{prompt_priority_list}->[$a] <=> $obj->{prompt_priority_list}->[$b])
		} 1..$obj->{prompt_num}) {
		$prompt .= $obj->{prompt}->[$_].' ' if $obj->{prompt}->[$_];
	}
	return $prompt;
}

sub get_command {
	my $obj = shift;
	$obj->print($obj->get_prompt);
	my $command = <>;
	return $command;
}

sub error {
	my $obj = shift;
	$obj->print("ERROR: ",join '',@_,"\n");
}

sub get_password {
	my $obj = shift;
	system 'stty -echo';
	$obj->print(shift || 'Password: ');
	my $pass = <>;  $pass =~ s/\n$//;
	system 'stty echo';
	print "\n";
	return $pass;
}

sub render_size {
	my $obj = shift;
	return 79;
}

sub register_prompt {
	my ($obj,$priority) = @_;
	$priority = 0 unless $priority;
	$obj->{prompt_priority_list}->[++$obj->{prompt_num}] = $priority;
	return $obj->{prompt_num};
}

sub add_to_actionlist {
	my $obj = shift;
	my $action = shift;
	push @{$obj->{actionlist}},$action;
}

sub filenames_complete {
	my $obj = shift;
	my $pattern = shift;

	my @files = (<$pattern*>);
	foreach (@files) {
	    $_ .= '/' if -d _;
	}
	return @files;
}

sub loop {
	my $obj = shift;
	my %action = ();

	do {
		%action = $obj->get_action();
		do {
			%action = $obj->{-core}->handle_action(%action);
		} until ($action{processed});
	} until ($action{action} eq 'QUIT');
}

sub history_clear {
	my $obj = shift;
	$obj->{history}->clear();
}
