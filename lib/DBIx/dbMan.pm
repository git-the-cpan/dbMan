package DBIx::dbMan;

use strict;
use vars qw/$VERSION/;
use DBIx::dbMan::Config;
use DBIx::dbMan::Lang;

$VERSION = '0.12';

sub new {
	my $class = shift;
	my $obj = bless { @_ }, $class;
	return $obj;
}

sub start {
	my $obj = shift;

	my $interface = $obj->{-interface};
	$interface = 'DBIx/dbMan/Interface/'.$interface.'.pm';
	eval { require $interface; };
	if ($@) { 
		$interface =~ s/\//::/g;
		$interface =~ s/\.pm$//;
		print STDERR "Can't locate interface module $interface\n";
		return;
	}
	$interface =~ s/\//::/g;
	$interface =~ s/\.pm$//;

	$obj->{config} = new DBIx::dbMan::Config;

	$obj->{lang} = new DBIx::dbMan::Lang;

	$obj->{interface} = $interface->new(-config => $obj->{config},
			-lang => $obj->{lang});
	$obj->{interface}->hello();

	$obj->load_extensions;

	my %action = ();

	do {
		%action = $obj->{interface}->get_action();
		do {
			%action = $obj->handle_action(%action);
		} until ($action{processed});
	} until ($action{action} eq 'QUIT');

	$obj->unload_extensions;

	$obj->{interface}->goodbye();
}

sub load_extensions {
	my $obj = shift;

	$obj->{extensions} = [];

	my %candidates = ();
	for my $dir ($obj->extensions_directories) {
		opendir D,$dir;
		for (grep /\.pm$/,readdir D) { 
			eval { require "$dir/$_"; };
			next if $@;
			s/\.pm$//;
			my $candidate = "DBIx::dbMan::Extension::".$_;
			my $id = '';
			eval { $id = $candidate->IDENTIFICATION(); };
			next unless $id or $@;
			my ($ident,$ver) = ($id =~ /^(.*)-(.*)$/);
			next if $ident eq '000001-000001';	# not ID
			if (exists $candidates{$ident}) {
				next if $candidates{$ident}->{-ver} <= $ver;
			}
			$candidates{$ident} = 
				{ -candidate => $candidate, -ver => $ver }; 
		};
		closedir D;
	}

	my %extensions = ();
	my $iterator = 0;
	for my $candidate (keys %candidates) {
		my $ext = undef;
		eval {
			$ext = $candidates{$candidate}->{-candidate}->new(
				-config => $obj->{config}, 
				-interface => $obj->{interface});
		};
		if (defined $ext and not $@) {
			my $preference = 0;
			eval { $preference = $ext->preference(); };
			$extensions{$preference.'_'.$iterator} = $ext;
			++$iterator;
		}
	}

	for (sort { 
			my ($fa,$sa,$fb,$sb) = split /_/,($a.'_'.$b); 
			if ($fa == $fb) { $sa <=> $sb; } else { $fb <=> $fa };
		} keys %extensions) {
		push @{$obj->{extensions}},$extensions{$_};
		$extensions{$_}->init();
	}
}

sub unload_extensions {
	my $obj = shift;

	for (@{$obj->{extensions}}) { $_->done();  undef $_; }
}

sub extensions_directories {
	my $obj = shift;
	my %alldirs = map { ($_ => 1) } (@INC,($obj->{config}->extensions_dir?
			($obj->{config}->extensions_dir):()),'.');
	my @dirs = ();
	for (map { my $tmp = $_; $tmp =~ s/\/$//; "$tmp/DBIx/dbMan/Extension"; }
			keys %alldirs) {
		push @dirs,$_ if -d $_;
	}
	return @dirs;
}

sub handle_action {
	my ($obj, %action) = @_;
		
	for my $ext (@{$obj->{extensions}}) {
		%action = $ext->handle_action(%action);
		return %action unless $action{processed};
		$action{processed} = undef;
	}

	$action{processed} = 1;
	return %action;
}

1;
