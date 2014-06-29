package ValueToken;
# This object represents a token whose value is scalar or string.
use strict;
use warnings;

use base qw(Token);

sub new($$$) {
  my $class = shift;
  my $name = shift;
  my $value = shift;
  my $self = new Token($name);
  bless($self, $class);
  $self->{value} = $value;
  return $self;
}

# Just return the value as is.
sub get_value($) {
  my $self = shift;
  return $self->{value};
}

sub process($$) {
  my $self = shift;
  my $context = shift;
  my $value = $self->{value};

  $context->{processed} .= $value;
  return $value;
}

1;
