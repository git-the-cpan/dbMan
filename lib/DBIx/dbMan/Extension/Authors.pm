package DBIx::dbMan::Extension::Authors;

use strict;
use vars qw/$VERSION @ISA %authorname/;
use DBIx::dbMan::Extension;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

# registered authornames
%authorname = (
	'000001' => 'Milan Sorm <sorm@pef.mendelu.cz>',
	'000002' => 'Frantisek Darena <darena@pef.mendelu.cz>'
);

1;

sub IDENTIFICATION { return "000001-000012-000001"; }

sub author { return 'Milan Sorm <sorm@pef.mendelu.cz>'; }

sub preference { return 0; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'AUTHORS') {
		my %authors = ();
		for my $ext (@{$obj->{-core}->{extensions}}) {
			my $id = $ext->IDENTIFICATION;
			$id =~ s/-.*//;
			++$authors{$id};
			if ($ext->can('author')) {
				$authorname{$id} = $ext->author();
			}
		}
		my $authors = '';
		for (sort keys %authors) {
			$authors .= "   ".((exists $authorname{$_})?$authorname{$_}:$_)."\n";
		}
		$action{action} = 'OUTPUT';
		$action{output} = "Program:\n   ".$authorname{'000001'}."\n\nExtensions:\n".$authors;
	}

	$action{processed} = 1;
	return %action;
}
