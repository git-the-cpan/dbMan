package DBIx::dbMan::MemPool;

use strict;
use vars qw/$VERSION/;
use locale;
use POSIX;

$VERSION = '0.01';

1;

sub new {
	my $class = shift;
	my $obj = bless { @_ }, $class;
	return $obj;
}

sub set {
	my $obj = shift;
	my $name = shift;
	$obj->{$name} = shift;
}

sub get {
	my $obj = shift;
	my $name = shift;
	return undef unless exists $obj->{$name};
	return $obj->{$name};
}

sub register {
	my $obj = shift;
	my $name = shift;
	for (@_) {
		++ $obj->{-registers}->{$name}->{$_};
	}
}

sub get_register {
	my $obj = shift;
	my $name = shift;
	return () unless exists $obj->{-registers};
	return () unless exists $obj->{-registers}->{$name};
	return keys %{$obj->{-registers}->{$name}};
}
