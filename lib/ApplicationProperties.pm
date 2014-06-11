package ApplicationProperties;

BEGIN {
  use Exporter;
  @ISA = qw(Exporter);
  @EXPORT = qw(get_application_properties);
}

use strict;
use warnings;

use base qw(Properties);

sub new($) {
  my $class = shift;
  my $self = new Properties('./config/Application.properties');
  if ($self) {
    bless($self, $class);
    our $properties = $self;
  }
  return $self;
}

sub get_application_properties() {
  return our $properties;
}

BEGIN {
  our $properties = 0;
}

1;
