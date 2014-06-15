package TestProperties;
# Object derived from Properties used to test Properties

# Export a function (not a method) which can retrieve the single
# instance of this object.
BEGIN {
  use Exporter;
  @ISA = qw(Exporter);
  @EXPORT = qw(get_test_properties);
}

use strict;
use warnings;

# Derive from Properties.
use base qw(Properties);

# Contructor.
sub new($) {
  my $class = shift;
  # Create a new Properties object and use it as your self.
  my $self = new Properties('./config/TestProperties.properties');

  # Bless our new self and save a pointer so we can make this a singleton.
  if ($self) {
    bless($self, $class);
    our $test_properties = $self;
  }
  return $self;
}

# This function (not a method) can be used to rentrieve the single instance of
# this object.
# This should actually create the instance if it doesn't exist.
# See Issue
sub get_test_properties() {
  our $test_properties;
  if (!$test_properties) {
    $test_properties = new TestProperties();
  }
  return $test_properties;
}

# This is where the pointer to the singleton object is kept.
BEGIN {
  our $test_properties = 0;
}

1;
