package ApplicationProperties;
# This is an example of deriving
# a new object from the Properties object.
# In this case the new object will hold application properties.
# These are always loaded a file in the ./config folder
# that shares the main application's filename with a '.properties' extension.

# Export a function (not a method) which can retrieve the single
# instance of this object.
BEGIN {
  use Exporter;
  @ISA = qw(Exporter);
  @EXPORT = qw(get_application_properties);
}

use strict;
use warnings;

# Derive from Properties.
use base qw(Properties);

# Contructor.
sub new($) {
  my $class = shift;
  # Create a new Properties object and use it as your self.
  my $self = new Properties('./config/Application.properties');

  # Bless our new self and save a pointer so we can make this a singleton.
  if ($self) {
    bless($self, $class);
    our $properties = $self;
  }
  return $self;
}

# This function (not a method) can be used to rentrieve the single instance of
# this object.
# This should actually create the instance if it doesn't exist.
# See Issue
sub get_application_properties() {
  return our $properties;
}

# This is where the pointer to the singleton object is kept.
BEGIN {
  our $properties = 0;
}

1;
