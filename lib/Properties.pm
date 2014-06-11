package Properties;
use strict;
use warnings;

use base qw(BaseObject);

# Project objects
use Log;

# Private functions
sub _strip_comments($);

sub new($$) {
  my $class = shift;
  my $file = shift;
  my $self = new BaseObject();
  bless($self, $class);
  return $self->load_properties($file);
}

sub load_properties($$) {
  my $self = shift;
  my $file_name = shift;
  my $log = $self->{log};

  if (open(PROPS,"$file_name")) {
    foreach my $line (<PROPS>) {
      $line = _strip_comments($line);
      next if not $line;
      my ($prop, $value) = split('=',$line);
      $self->{$prop} = $value;
      $log->add_entry("Properties from $file_name: $prop=$self->{$prop}\n",0);
    }
    close(PROPS);
  }
  else {
    $log->add_entry("Failed to load properties from file $file_name. Error: $!\n");
    $self = 0;
  }
  return $self;
}

# private functions
sub _strip_comments($) {
  my $input = shift;
  $input =~ s/#.*$//;
  $input =~ s/\s*$//;
  return $input;
}
1;
