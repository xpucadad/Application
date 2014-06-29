package Token;
# The abstract base class for all tokens
use strict;
use warnings;

use base qw(BaseObject);

sub new($$) {
  my $class = shift;
  my $name = shift;
  my $type = shift;
  my $self = new BaseObject();
  bless($self, $class);
  $self->{name} = $name;
  return $self;
}

# This would be an abstract class if this wasn't perl.
# As far as I know this is the best we can currently do.
# I'm tempted to failfast here.
sub get_value($) {
  my $self = shift;
  my $log = $self->{log};
  my $type = ref($self);
  $log->add_entry("WARNING: Token: $type must define the get_value method!\n");
  return 0;
}

# Another abstract function
sub process($$) {
  my $self = shift;
  my $type = ref($self);
  $self->{log}->add_entry("WARNING: Token: $type must define process method!\n");
  return 0;
}

# Return this token's name
sub get_name($) {
  my $self = shift;
  return $self->{name};
}

# Return this token's (object) type.
sub get_type($) {
  my $self = shift;
  return ref($self);
}

1;
