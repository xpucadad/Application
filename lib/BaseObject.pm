package BaseObject;

BEGIN {
  use Exporter;
  @ISA = qw(Exporter);
  @EXPORT = qw(get_time_stamp);
}

use strict;
use warnings;

use Log;

sub new($) {
  my $class = shift;
  my $self = {};
  bless($self, $class);
  return $self->init();
}

sub init($) {
  my $self = shift;

  # If the log has been initialized, store it.
  # If this is the init from the child Log object, the
  # value will not be set yet, so we can't set it.
  my $log = get_log();
  if ($log) {
    # Make the log available derived objects as
    # $self->{log}.
    $self->{log} = $log;
  }
  return $self;
}

1;
