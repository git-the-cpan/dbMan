package DBIx::dbMan::Extension::Describe;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000032-000001"; }

sub preference { return 0; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'DESCRIBE') {
		$action{action} = 'NONE';
		unless ($obj->{-dbi}->current) {
			$obj->{-interface}->error("No current connection selected.");
			return %action;
		}	

		my $table = new Text::FormatTable '| l | l | l | l | l |';
		$table->rule;
		$table->head('COLUMN','TYPE','SIZE','SCALE','NULLABLE');
		$table->rule;

		my $sth = $obj->{-dbi}->prepare(q!SELECT * FROM !.$action{what}.q! WHERE 0 = 1!);
		my $ret = $sth->execute();
		if (defined $ret) {
			my @type = map { (defined $obj->{-dbi}->type_info($_)) 
				? (scalar $obj->{-dbi}->type_info($_)->{TYPE_NAME})
				: $_ } @{$sth->{TYPE}};
			my @prec = @{$sth->{PRECISION}};
			my @scale = @{$sth->{SCALE}};
			my @null = @{$sth->{NULLABLE}};
			my %nullcvt = qw/0 no 1 yes 2 unknown/;
			$nullcvt{''} = 'no';
			for (@{$sth->{NAME}}) {
				$table->row($_,shift @type,shift @prec,shift @scale,$nullcvt{shift @null});
			}
		} else {
			$obj->{-interface}->error("Table $action{what} not found.");
			return %action;
		}
		$sth->finish;
		$table->rule;
		$action{action} = 'OUTPUT';
		$action{output} = $table->render($obj->{-interface}->render_size);
	}

	$action{processed} = 1;
	return %action;
}
