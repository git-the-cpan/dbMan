package DBIx::dbMan::Extension::Clear;

use strict;
use base 'DBIx::dbMan::Extension';

our $VERSION = '0.03';

1;

sub IDENTIFICATION { return "000001-000057-000003"; }

sub preference { return 0; }

sub known_actions { return [ qw/SCREEN/ ]; }

sub handle_action {
	my ($obj,%action) = @_;

	if ($action{action} eq 'SCREEN') {
		if ($action{operation} eq 'clear') {
			eval {
				use Term::Screen;

				my $scr = new Term::Screen;
				die "no" unless $scr;
				$scr->clrscr();
			};
			if ($@) { # fallback
				my $oldpath = $ENV{PATH};
				$ENV{PATH} = '';
				system '/usr/bin/clear';
				$ENV{PATH} = $oldpath;
			}
			$action{action} = 'NONE';
		}
	}

	$action{processed} = 1;
	return %action;
}
