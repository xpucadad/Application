package FunctionToken;
# This object represents a token whose value is a function to call that
# returns the final value.
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

# Get the final value of the token by executing the function stored as the
# token's value.
sub get_value($) {
  my $self = shift;
  my $function = $self->{value};
  my $return = &$function();
  return $return;
}

1;
