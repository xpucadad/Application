package ArrayToken;
# This object represents a token whose value is an array where each entry
# in the area represests a row of a table and contains values of the columns
# for that row.
use strict;
use warnings;

use base qw(Token);

sub new($$$) {
  my $class = shift;
  my $name = shift;
  my $value = shift;
  my $self = new Token($name);
  bless($self, $class);
  return $self->init($value);
}

sub init($$) {
  my $self = shift;
  my $array = shift;

  return $self;
}

# Get the final value of the token by creating the rows for the table
sub get_value($) {
  my $self = shift;
  my $return = 'not yet implemented';
  return $return;
}

# Processes all the values in the token into lines based on the token's tag in
# the template.
sub process($$) {
  my $self = shift;
  my $context = shift;
  my $value = $self->get_value();

  $context->{processed} .= $value;
  return $value;
}

1;
