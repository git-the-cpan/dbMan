package DBIx::dbMan::DBI;

use strict;
use vars qw/$VERSION $AUTOLOAD/;
use locale;
use POSIX;
use DBIx::dbMan::Config;
use DBI;

$VERSION = '0.03';

1;

sub new {
	my $class = shift;
	my $obj = bless { @_ }, $class;
	$obj->clear_all_connections;
	$obj->load_connections;
	return $obj;
}

sub connectiondir {
	my $obj = shift;

	return $ENV{DBMAN_CONNECTIONDIR} if $ENV{DBMAN_CONNECTIONDIR};
	return $obj->{-config}->connection_dir if $obj->{-config}->connection_dir;
	mkdir $ENV{HOME}.'/.dbman/connections' unless -d $ENV{HOME}.'/.dbman/connections';
	return $ENV{HOME}.'/.dbman/connections';
}

sub clear_all_connections {
	my $obj = shift;
	$obj->{connections} = {};
}

sub load_connections {
	my $obj = shift;
	my $cdir = $obj->connectiondir;
	return -1 unless -d $cdir;
	opendir D,$cdir;
	my @connections = grep !/^\.\.?/,readdir D;
	for (@connections) { $obj->load_connection($_); }
	$obj->be_quiet(1); $obj->set_current();  $obj->be_quiet(0);
	if ($obj->{-config}->current_connection) {
		$obj->set_current($obj->{-history}->current_connection);
	}
	closedir D;
}

sub load_connection {
	my ($obj,$name) = @_;
	my $cdir = $obj->connectiondir;
	return -1 unless -d $cdir;
	$cdir =~ s/\/$//;
	return -2 unless -f "$cdir/$name";
	open F,"$cdir/$name" or return -2;
	close F;
	my $lcfg = new DBIx::dbMan::Config -file => "$cdir/$name";
	my %connection;
	for ($lcfg->all_tags) { $connection{$_} = $lcfg->$_; }
	$obj->{connections}->{$name} = \%connection;
	if ($lcfg->auto_login) { $obj->open($name); }
}

sub open {
	my ($obj,$name) = @_;

	unless (exists $obj->{connections}->{$name}) {
		$obj->{-interface}->error("Unknown connection $name.");
		return;
	}

	if ($obj->{connections}->{$name}->{-logged}) {
		$obj->{-interface}->print("Already connected to $name.\n") unless $obj->{quite};
		return;
	}

	my @driver_names = DBI->available_drivers;
	my $found = 0;
	for (@driver_names) {
		++$found if $_ eq $obj->{connections}->{$name}->{driver};
	}
	unless ($found) { 
		$obj->{-interface}->error("Can't find driver for ".
			$obj->{connections}->{$name}->{driver}.".");  
		return -1; 
	}

	my $dbi = DBI->connect('dbi:'.$obj->{connections}->{$name}->{driver}.
		':'.$obj->{connections}->{$name}->{dsn},
		$obj->{connections}->{$name}->{login},
		$obj->{connections}->{$name}->{password},
		{ PrintError => 0, RaiseError => 0, AutoCommit => 1, LongTruncOk => 1 });

	unless (defined $dbi) {
		$obj->{-interface}->error("Can't connect to ".$name." (reason: ".DBI->errstr.").");
		return -2; 
	}

	$obj->{connections}->{$name}->{-dbi} = $dbi;
	$obj->{connections}->{$name}->{-logged} = 1;

	$obj->{-interface}->print("Connection to ".$name." established.\n") unless $obj->{quite};
	$obj->{-interface}->add_to_actionlist({ action => 'AUTO_SQL', connection => $name });
	return 0;
}

sub close {
	my ($obj,$name) = @_;

	unless (exists $obj->{connections}->{$name}) {
		$obj->{-interface}->error("Unknown connection $name.");
		return -1;
	}
	unless ($obj->{connections}->{$name}->{-logged}) {
		$obj->{-interface}->print("Not connected to $name.\n") unless $obj->{quite};
		return -2;
	}
	if ($obj->{current} eq $name) { $obj->set_current(); }
	delete $obj->{connections}->{$name}->{-logged};
	$obj->{connections}->{$name}->{-dbi}->disconnect();
	undef $obj->{connections}->{$name}->{-dbi};

	$obj->{-interface}->print("Disconnect from ".$name.".\n") unless $obj->{quite};
	return 0;
}

sub close_all {
	my $obj = shift;
	for my $name (keys %{$obj->{connections}}) {
		$obj->close($name) if $obj->{connections}->{$name}->{-logged};
	}
}

sub DESTROY {
	my $obj = shift;
	$obj->close_all;
}

sub list {
	my ($obj,$what) = @_;
	my @returned = ();

	for my $name (keys %{$obj->{connections}}) {
		my %r = %{$obj->{connections}->{$name}};
		if ($what eq 'active') { next unless $r{-logged}; }
		$r{name} = $name;
		push @returned, \%r;
	}

	return [ sort { $a->{name} cmp $b->{name} } @returned ];
}

sub autosql {
	my $obj = shift;

	unless ($obj->{current}) {
		$obj->{-interface}->error("No current connection.");
		return -1;
	}
	unless (exists $obj->{connections}->{$obj->{current}}) {
		$obj->{-interface}->error("Unknown connection $obj->{current}.");
		return -2;
	}
	return $obj->{connections}->{$obj->{current}}->{autosql};
}

sub set_current {
	my ($obj,$name) = @_;
	unless ($name) {
		delete $obj->{current};
		$obj->{-interface}->print("Unset current connection.\n") unless $obj->{quite};
		return 0;
	}

	unless (exists $obj->{connections}->{$name}) {
		$obj->{-interface}->error("Unknown connection $name.");
		return -1;
	}
	unless ($obj->{connections}->{$name}->{-logged}) {
		$obj->{-interface}->print("Not connected to $name.\n") unless $obj->{quite};
		return -2;
	}
	$obj->{current} = $name;
	$obj->{-interface}->print("Set current connection to ".$name.".\n") unless $obj->{quite};
	return 0;
}

sub current {
	my $obj = shift;
	return $obj->{current};
}

sub drop_connection {
	my $obj = shift;
	my $name = shift;
	unless (exists $obj->{connections}->{$name}) {
		$obj->{-interface}->print("Connection with name ".$name." not exists.\n") unless $obj->{quite};
		return -1;
	}
	if ($obj->{connections}->{$name}->{-logged}) {
		$obj->close($name);
	}
	delete $obj->{connections}->{$name};
	$obj->{-interface}->print("Connection ".$name." droped.\n") unless $obj->{quite};
}

sub create_connection {
	my $obj = shift;
	my $name = shift;
	my $p = shift;
	my %parms = %$p;
	if (exists $obj->{connections}->{$name}) {
		$obj->{-interface}->print("Connection with name ".$name." already exists.\n") unless $obj->{quite};
		return -1;
	}
	$obj->{connections}->{$name} = \%parms;
	$obj->{-interface}->print("Connection ".$name." created.\n") unless $obj->{quite};
	if ($parms{auto_login}) { $obj->open($name); }
}

sub save_connection {
	my $obj = shift;
	my $name = shift;
	
	unless (exists $obj->{connections}->{$name}) {
		$obj->{-interface}->print("Connection with name ".$name." not exists.\n") unless $obj->{quite};
		return -1;
	}

	my $cdir = $obj->connectiondir;
	mkdir $cdir unless -d $cdir;
	return -1 unless -d $cdir;
	$cdir =~ s/\/$//;
	open F,">$cdir/$name" or return -2;
	for (qw/driver dsn login password auto_login/) {
		print F "$_ ".$obj->{connections}->{$name}->{$_}."\n"
			if exists $obj->{connections}->{$name}->{$_}
				and $obj->{connections}->{$name}->{$_} ne '';
	}	
	close F;
	chmod 0600,"$cdir/$name";
	$obj->{-interface}->print("Making connection ".$name." permanent.\n") unless $obj->{quite};
	return 0;
}

sub destroy_connection {
	my $obj = shift;
	my $name = shift;
	
	my $cdir = $obj->connectiondir;
	return -1 unless -d $cdir;
	$cdir =~ s/\/$//;
	return 0 unless -e "$cdir/$name";
	unlink "$cdir/$name";
	if (-e "$cdir/$name") {
		$obj->{-interface}->error("Can't destroy connection ".$name.".\n");
		return -2;
	}
	$obj->{-interface}->print("Destroying permanent connection ".$name.".\n") unless $obj->{quite};
	return 0;
}

sub is_permanent_connection {
	my $obj = shift;
	my $name = shift;
	my $cdir = $obj->connectiondir;
	return 0 unless -d $cdir;
	$cdir =~ s/\/$//;
	return -e "$cdir/$name";
}

sub trans_begin {
	my $obj = shift;
	return -1 unless $obj->{current};
	$obj->{connections}->{$obj->{current}}->{-dbi}->{AutoCommit} = 0;
}

sub trans_end {
	my $obj = shift;
	return -1 unless $obj->{current};
	$obj->{connections}->{$obj->{current}}->{-dbi}->{AutoCommit} = 1;
}

sub in_transaction {
	my $obj = shift;
	return 0 unless $obj->{current};
	return not $obj->{connections}->{$obj->{current}}->{-dbi}->{AutoCommit};
}

sub be_quiet {
	my ($obj,$mode) = @_;
	$obj->{quite} = $mode;
}

sub driver {
	my $obj = shift;
	return undef unless $obj->{current};
	return $obj->{connections}->{$obj->{current}}->{driver};
}

sub login {
	my $obj = shift;
	return undef unless $obj->{current};
	return $obj->{connections}->{$obj->{current}}->{login};
}

sub AUTOLOAD {
	my $obj = shift;

	$AUTOLOAD =~ s/^DBIx::dbMan::DBI:://g;
	return undef unless $obj->{current};
	return undef unless exists $obj->{connections}->{$obj->{current}};
	return undef unless $obj->{connections}->{$obj->{current}}->{-logged};
	return undef unless defined $obj->{connections}->{$obj->{current}}->{-dbi};
	my $dbi = $obj->{connections}->{$obj->{current}}->{-dbi};
	return $dbi->$AUTOLOAD(@_);
}

sub set {
	my ($obj,$var,$val) = @_;
	return unless $obj->{current};
	$obj->{connections}->{$obj->{current}}->{$var} = $val;
}

sub get {
	my ($obj,$var) = @_;
	return undef unless $obj->{current};
	return $obj->{connections}->{$obj->{current}}->{$var};
}
