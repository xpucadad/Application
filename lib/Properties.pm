package Properties;
#
# This is the base class for loading a properties file.
# Derive subclasses as needed if you have multiple property files.
#
use strict;
use warnings;

use base qw(BaseObject);

# Project objects
use Log;

# Private functions
sub _strip_comments($);

# Constructor.
# 0: class
# 1: property file to load
# r: the new Properties object; 0 if the object
#    creation fails for any reason.
sub new($$) {
  my $class = shift;
  my $file = shift;
  my $self = new BaseObject();
  bless($self, $class);
  return $self->load_properties($file);
}

# Loads the properties from the file into this
# Properties object.
# 0: self
# 1: name of properties file
# r: this Properties object or 0 if the load fails
#    for any reason.
sub load_properties($$) {
  my $self = shift;
  my $file_name = shift;
  my $log = $self->{log};

  if (open(PROPS,"$file_name")) {
    # Process each line
    foreach my $line (<PROPS>) {
      # Strip comments
      $line = _strip_comments($line);
      next if not $line;  # The line was nothing but a comment so skip it.

      # The property is of the form <name>=<value>
      # We currently don't trim either, but perhaps we should.
      # See Issue #6.
      my ($prop, $value) = split('=',$line);
      $self->{$prop} = $value;
      $log->add_entry("Property from $file_name: $prop=$self->{$prop}\n",0);
    }
    close(PROPS);
  }
  else {
    # The load failed. Log an error and deref ourself.
    $log->add_entry("Failed to load properties from file $file_name. Error: $!\n");
    $self = 0;
  }
  return $self;
}

# private functions

# Strips comments a string.
sub _strip_comments($) {
  my $input = shift;

  # Remove the last '#' and everything after it.
  # Maybe we should remove the 1st # and everything after it.
  # See Issue #7
  $input =~ s/#.*$//;

  # Strip any remaining whitespace at the end of the line.
  $input =~ s/\s*$//;

  return $input;
}

1;
