package DBIx::dbMan::Extension::HelpCommands;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;
use Text::FormatTable;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000010-000001"; }

sub preference { return 0; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'HELP') {
		if ($action{type} eq 'commands') {
			my @help = ();
			for my $ext (@{$obj->{-core}->{extensions}}) {
				if ($ext->can('cmdhelp')) {
					my %h = @{$ext->cmdhelp()};
					for (keys %h) {
						push @help,[ $_, $h{$_} ];
					}
				}
			}
			my $table = new Text::FormatTable '| l l | l |';
			$table->rule;
			for (sort { $a->[0] cmp $b->[0] } @help) {
				$table->row(' * ',@$_);
			}
			$table->rule;
			$action{action} = 'OUTPUT';
			$action{output} = $table->render($obj->{-interface}->render_size);
		}
	}

	$action{processed} = 1;
	return %action;
}
