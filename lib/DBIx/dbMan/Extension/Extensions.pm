package DBIx::dbMan::Extension::Extensions;

use strict;
use vars qw/$VERSION @ISA/;
use DBIx::dbMan::Extension;
use Text::FormatTable;

$VERSION = '0.01';
@ISA = qw/DBIx::dbMan::Extension/;

1;

sub IDENTIFICATION { return "000001-000008-000001"; }

sub preference { return 0; }

sub handle_action {
	my ($obj,%action) = @_;

	$action{processed} = 1;
	if ($action{action} eq 'EXTENSION') {
		if ($action{operation} eq 'show') {
			my $table = new Text::FormatTable '| r | l | l |';
			$table->rule;
			$table->head('PRI','NAME','IDENTIFICATION');
			$table->rule;
			for my $ext (@{$obj->{-core}->{extensions}}) {
				my $name = $ext;
				$name =~ s/=.*$//;  $name =~ s/^.*:://;
				my $id = $ext->IDENTIFICATION;
				$table->row($ext->preference,$name,$id);
			}
			$table->rule;

			$action{action} = 'OUTPUT';
			$action{output} = $table->render($obj->{-interface}->render_size);
		} elsif ($action{operation} =~ /^(un|re)load$/) {
			$action{action} = 'NONE';
			my $i = 0;  my $unload = undef;  my $name = '';
			for my $ext (@{$obj->{-core}->{extensions}}) {
				$name = $ext;  $name =~ s/=.*$//;  $name =~ s/^.*:://;
				if (lc $name eq lc $action{what}) { $unload = $i;  last; }
				++$i;
			}
			if (defined $unload) {
				$obj->{-core}->{extensions}->[$unload]->done();
				undef $obj->{-core}->{extensions}->[$unload];
				splice @{$obj->{-core}->{extensions}},$unload,1;
				$action{action} = 'OUTPUT';
				$action{output} = "Extension $name unloaded.\n" if $action{operation} eq 'unload';
			} else {
				$obj->{-interface}->error("Extension $action{what} not exists.");
				return %action;
			}
		}
		if ($action{operation} =~ /^(re)?load$/) {
			$action{action} = 'NONE';
			my %loaded = ();
			for my $ext (@{$obj->{-core}->{extensions}}) {
				my $id = $ext->IDENTIFICATION;
				$id =~ s/-[^-]+$//;  ++$loaded{$id};
			}

			my $name = $action{what};
			my %candidates = ();
			for my $dir ($obj->{-core}->extensions_directories) {
				opendir D,$dir;
				for (grep /\.pm$/,readdir D) { 
					next unless lc $_ eq lc $action{what}.".pm";
					eval { require "$dir/$_"; };
					next if $@;
					{
						undef $/;
						if (open F,"$dir/$_") {
							eval <F>;
							close F;
						}
					}
					eval { require "$dir/$_"; };
					next if $@;
					s/\.pm$//;
					my $candidate = "DBIx::dbMan::Extension::".$_;
					$name = $_;
					my ($low,$high) = ('','');
					eval { ($low,$high) = $candidate->for_version(); };
					next if $low and $DBIx::dbMan::VERSION < $low;
					next if $high and $DBIx::dbMan::VERSION > $high;
					my $id = '';
					eval { $id = $candidate->IDENTIFICATION(); };
					next unless $id or $@;
					my ($ident,$ver) = ($id =~ /^(.*)-(.*)$/);
					next if $ident eq '000001-000001';	# not ID
					if (exists $loaded{$ident}) {
						$obj->{-interface}->error("Extension $name already loaded.");
						return %action;
					}
					if (exists $candidates{$ident}) {
						next if $candidates{$ident}->{-ver} <= $ver;
					}
					$candidates{$ident} = 
						{ -candidate => $candidate, -ver => $ver }; 
				};
				closedir D;
			}
			if (keys %candidates) { 
				my %extensions = ();
				for my $candidate (keys %candidates) {
					my $ext = undef;
					eval {
						$ext = $candidates{$candidate}->{-candidate}->new(
							-config => $obj->{-core}->{config}, 
							-interface => $obj->{-core}->{interface},
							-dbi => $obj->{-core}->{dbi},
							-core => $obj->{-core},
							-mempool => $obj->{-core}->{mempool});
					};
					if (defined $ext and not $@) {
						my $preference = 0;
						eval { $preference = $ext->preference(); };
						$ext->{'___sort_criteria___'} = $preference.'_'.$obj->{extension_iterator};
						++$ext->{'___need_init___'};
						$extensions{$preference.'_'.$obj->{-core}->{extension_iterator}} = $ext;
						++$obj->{-core}->{extension_iterator};
					}
				}

				for my $ext (@{$obj->{-core}->{extensions}}) {
					my $sc = $ext->{___sort_criteria___};
					$extensions{$sc} = $ext;
				}
				
				$obj->{-core}->{extensions} = [];
				for (sort { 
						my ($fa,$sa,$fb,$sb) = split /_/,($a.'_'.$b); 
						if ($fa == $fb) { $sa <=> $sb; } else { $fb <=> $fa };
					} keys %extensions) {
					push @{$obj->{-core}->{extensions}},$extensions{$_};
					$extensions{$_}->init() if $extensions{$_}->{'___need_init___'};
					delete $extensions{$_}->{'___need_init___'};
				}

				$action{action} = 'OUTPUT';
				$action{output} = "Extension $name $action{operation}ed successfully.\n";
			} else {
				$obj->{-interface}->error("Extension $action{what} not found.");
			}
		}
	}

	return %action;
}
