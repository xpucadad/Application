package Template;
#
# This is the base class for preparing a sting based on template containing
# tokens which are replaced with supplied values.
use strict;
use warnings;

use base qw(BaseObject);
our (@ISA, @EXPORT_OK);
BEGIN {
  require Exporter;
  @ISA = qw(Exporter);
  @EXPORT_OK = qw(current_date current_time current_date_time);  # symbols to export on request
}

# Project objects
use Log;
use Tokens;

# Constructor.
# 0: class
# 1: template file to use
# r: the new Template object; 0 if the object
#    creation fails for any reason.
sub new($$) {
  my $class = shift;
  my $file = shift;
  my $self = new BaseObject();
  bless($self, $class);
  return $self->init($file);
}

# Initialize the Template object.
# - read in the template file
# - get a Tokens object to hold the tokens
# 0: self
# 1: template file name.
# r: self
sub init($$) {
  my $self = shift;
  my $file = shift;
  my $log = $self->{log};
  # Try to load the template file into a string.
  my $path = "./config/".$file;
  #print "path: $path\n";

  # If the template file doesn't exist, we're done.
  if (-e $path) {
    # The template file exists - read it in
    if (open(TEMP, $path)) {
      # Successfully opened for read, so complete our setup.
      my @template = <TEMP>;
      close(TEMP);
      $self->{template_file} = $file;
      $self->{template_array} = \@template;
      $self->{template_path} = $path;
      $self->{tokens} = new Tokens();
      $log->add_entry("Template: loaded template from file $path.\n",0);
    }
    else {
      # Failed to open the template file so we need to fail.
      $log->add_entry("Template: failed to load template file $path; Error: $!\n");
      $self = 0;
    }
  }
  else {
    # The template file does not exist so we need to fail.
    $log->add_entry("Template: cannot find template file \'$path\'.\n");
    $self = 0;
  }
  return $self;
}

sub get_template_file_name($) {
  my $self = shift;
  return $self->{template_file};
}

# Sets the value associated with a template name.
# 0: self
# 1: token name
# 2: token value
# r: the created token object
sub set_token_value($$$) {
  my $self = shift;
  my $name = shift;
  my $value = shift;
  my $tokens = $self->{tokens};
  $tokens->set_token_value($name, $value);
  my $token = $tokens->get_token($name);
  return $token;
}

# Sets multiple token values provide in a hash
# 0: self
# 1: A hash with token name:value pairs.
# r: none
sub set_token_values($$) {
  my $self = shift;
  my $new_tokens = shift;
  my $tokens = $self->{tokens};

  foreach my $name (%$new_tokens) {
    $tokens->set_token_value($name, $new_tokens->{$name});
  }
}

# Gets a token's value from the token by way of the tokens hash and returns it.
# 0: self
# 1: token name
# r: token's fully resolved value
sub get_token_value($$) {
  my $self = shift;
  my $name = shift;
  return $self->{tokens}->get_token_value($name);
}

# Returns the token hash
sub get_tokens($) {
  my $self = shift;
  return $self->{tokens};
}

# Applies the current token to the template and returns the processed results.
sub get_processed_output($) {
  my $self = shift;
  $self->_process();
  return $self->{processed_results};
}

#
# Local methods
#

# Applies the tokens to the template and stores the result in processed_results.
sub _process($) {
  my $self = shift;
  my $log = $self->{log};
  my $processed_template;

  # Process each line in the template
  foreach my $line (@{$self->{template_array}}) {
    $processed_template .= $self->_process_line($line);
  }
  $self->{processed_results} = $processed_template;
}

# Apply the tokens to a single line and return the processed results.
sub _process_line($$) {
  my $self = shift;
  my $line = shift;
  my $processed_line = '';

  # Process the tokens in the line in order.
  my $name;
  my $end;
  my $value;
  my $type;
  while (length($line)) {
    if ($line =~ /(.*?)<%([^%]+)%>(.*)$/) {
      $processed_line .= $1;
      $name = $2;
      $end = $3;
      $value = $self->get_token_value($name);
      $processed_line .= $value;
      $line = $end;
    }
    else {
      $processed_line .= $line;
      $line = '';
    }
  }
  return $processed_line;
}

#
# Convenience functions
#
sub current_date() {
  my ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
  my $ts = sprintf("%4d-%02d-%02d",
          $year + 1900, $mon + 1, $mday);
  return $ts;
}

sub current_time() {
  my ($sec,$min,$hour) = localtime(time);
  my $ts = sprintf("%02d:%02d:%02d",
          $hour, $min, $sec);
  return $ts;
}

sub current_date_time() {
  my ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
  my $ts = sprintf("%4d-%02d-%02d %02d:%02d:%02d",
          $year + 1900, $mon + 1, $mday,
          $hour, $min, $sec);
  return $ts;
}
1;
