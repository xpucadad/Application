package ApplicationUtilities;

BEGIN {
  use Exporter;
  @ISA = qw(Exporter);
  @EXPORT = qw(failure_exit success_exit);
}

use strict;
use warnings;
use base qw(BaseObject);

# Application objects
use Log;

# If the application requires that some context information be maintained,
# the constructor would be enhanced to allow creation of an object which
# could maintain information to be used by other methods. Most functionality,
# however, would be implemented as function which do not require an object
# instance.
sub new($) {
  my $class = shift;
  my $self = new BaseObject();
  bless($self,$class);
  return $self;
}

# Functions (not methods - no instance of the object is needed)
# Logs a generic message and then exits with the supplied status or -1
# if no status was supplied.
# This will eventually be come part of a failfast implementation.
sub failure_exit(;$) {
  my $status = -1;
  if (@_ > 0) {
    $status = shift;
  }

  my $log = get_log();
  if ($log) {
    $log->add_entry("Script failed; exitting with status $status\n");
    $log->close();
  }
  exit($status)
}

sub success_exit(;$) {
  my $status = 0;
  $status = shift if (@_ > 0);
  my $log = get_log();
  if ($log) {
    $log->add_entry("Script completed successfully; exitting with status $status\n");
    $log->close();
  }
  exit ($status);
}
1;
