package Properties;
use strict;
use warnings;

use base qw(BaseObject);

# Project objects
use Log;

sub new($$) {
  my $class = shift;
  my $file = shift;
  my $self = new BaseObject();
  bless($self, $class);
  return $self->load_properties($file);
}

sub load_properties($$) {
  my $self = shift;
  my $filename = shift;

  if (open(PROPS,"./config/$filename")) {

  }
  else {
    my $log = $self->{log};
    $log->add_entry("Failed to load properties files $filename. Error: $!\n");
    $self = 0;
  }
  return $self;
}
1;
