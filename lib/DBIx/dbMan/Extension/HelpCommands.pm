package DBIx::dbMan::Extension::HelpCommands;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;
use Text::FormatTable;

$VERSION = '0.04';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000010-000004"; }

sub preference { return 0; }

sub known_actions { return [ qw/HELP/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'HELP') {
		if ($action{type} eq 'commands') {
			my @help = ();
			for my $ext (@{$obj->{-core}->{extensions}}) {
				if ($ext->can('cmdhelp')) {
					my %h = @{$ext->cmdhelp()};
					for (keys %h) {
						study $action{what} if $action{what};
						push @help,[ $_, $h{$_} ] if /^\Q$action{what}/i;
					}
				}
			}
			if (@help) {
				my $table = new Text::FormatTable '| l l | l |';
				$table->rule;
				for (sort { $a->[0] cmp $b->[0] } @help) {
					$table->row(' * ',@$_);
				}
				$table->rule;
				$action{output} = $table->render($obj->{-interface}->render_size);
			} else {
				$action{output} = "I havn't help for command ".$action{what}.".\n";
			}
			$action{action} = 'OUTPUT';
		} elsif ($action{type} eq 'version') {
			$action{action} = 'OUTPUT';
			$action{output} = "dbMan version is ".$DBIx::dbMan::VERSION."\n";
		}
	}

	$action{processed} = 1;
	return %action;
}
