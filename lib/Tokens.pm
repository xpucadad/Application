package Tokens;
# This class is used to hold the tokens that supply the values in a Template.
use strict;
use warnings;

use base qw(BaseObject);
use ValueToken;
use FunctionToken;

sub new($) {
  my $class = shift;
  my $self = new BaseObject();
  bless($self, $class);
  $self->{tokens} = {};
  return $self;
}

# This function creates a new Token of the appropriate type based on the type
# of value. It stores it in its token hash keyed by the token name.
# 0: self
# 1: token name
# 2: token value
# r: the created token object
sub set_token_value($$$) {
  my $self = shift;
  my $name = shift;
  my $value = shift;
  my $ref = ref($value);
  my $token;
  # Choose the appropriate type of token to create
  if ($ref eq 'CODE') {
    $token = new FunctionToken($name, $value);
  }
  else {
    $token = new ValueToken($name, $value);
  }
  # Save token in our name-to-token hash.
  $self->{tokens}->{$name} = $token;
  return $token;
}

# Returns a token value or the name in <%...%> if there is no such token.
# 0: self
# 1: token name
# r: token value or "<%token name%>" if the token hasn't been defined.
sub get_token_value($$) {
  my $self = shift;
  my $name = shift;
  my $token = $self->{tokens}->{$name};
  my $value = "<%$name%>";
  if ($token) {
    $value = $token->get_value();
  }
  else {
    $self->{log}->add_entry("WARNING: Tokens: token \'$name\' is not defined!\n");
  }
  return $value;
}

sub process_token($$$) {
  my $self = shift;
  my $name = shift;
  my $context = shift;
  my $token = $self->{tokens}->{$name};
  if ($token) {
    $token->process($context);
  }
  else {
    $self->{log}->add_entry("WARNING: Tokens: token \'$name\' is not defined!\n");
    $context->{processed} .= $context->{token_tag};
  }
}

# Returns the Token object for the $name.
# 0: self
# 1: token name
# r: The Token object
sub get_token($$) {
  my $self = shift;
  my $name = shift;
  my $token = $self->{tokens}->{$name};
  return $token;
}

# Dumps all the defined tokens
sub dump_tokens($) {
  my $self = shift;
  my $log = $self->{log};
  my $tokens = $self->{tokens};
  $log->add_entry("Tokens:\n");
  foreach my $name (keys(%$tokens)) {
    my $token = $tokens->{$name};
    my $value = $token->get_value();
    my $type = $token->get_type();
    $log->add_entry("\tname: $name; value: $value; type: $type\n");
  }
}

1;
