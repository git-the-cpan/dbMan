package DBIx::dbMan::Extension;

use strict;
use vars qw/$VERSION/;

$VERSION = '0.03';

1;

# identification: author-module-version
sub IDENTIFICATION { return "000001-000001-000003"; }

# author list:
# 000001 Ing. Milan Sorm <sorm@pef.mendelu.cz>
# 000002 Ing. Frantisek Darena <darena@pef.mendelu.cz>
# 000003 Ales Kutin <kutin@pef.mendelu.cz>
# 000004 Ondrej Kudlik <kudlik@pef.mendelu.cz>
# 999999 test user (not for redistributable)

# dbMan use only one instance from author-module with the highest version
# module 000001-000001 can't be loaded (not override IDENTIFICATION)

sub new {
	my $class = shift;
	my $obj = bless { @_ }, $class;
	return $obj;
}

sub preference { return 0; } 
# higher value, higher priority in calling
#        <0 fallback modules
#    0- 999 low priority - lowlevel (database) interface
# 1000-1999 medium priority - command parsers
# 2000-2999 high priority - preprocessors
# 3000-     super priority

sub for_version { return ('0.21',''); }

sub known_actions { return undef; }

sub init { };

sub done { };

# handle_action must set processed to 1 if done
# otherwise new handling of action in all extensions will be started
sub handle_action { 
	my ($obj,%action) = @_;
	$action{processed} = 1;
	return %action;
}
