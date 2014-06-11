package BaseObject;

BEGIN {
  use Exporter;
  @ISA = qw(Exporter);
  @EXPORT = qw(get_time_stamp);
}

use strict;
use warnings;

sub new($) {
  my $class = shift;
  my $self = {};
  bless($self, $class);
}

1;
