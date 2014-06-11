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
  my $log = get_log();
  if ($log) {
    $self->{log} = $log;
  }
  return $self;
}
1;
