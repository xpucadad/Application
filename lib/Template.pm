package Template;
#
# This is the base class for preparing a sting based on template containing
# tokens which are replaced with supplied values.
use strict;
use warnings;

use base qw(BaseObject);

# Perl modules
use File::Slurp;

# Project objects
use Log;

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

sub init($$) {
  my $self = shift;
  my $file = shift;
  my $log = $self->{log};
  # Try to load the template file into a string.
  my $path = "./config/".$file;
  #print "path: $path\n";
  if (-e $path) {
    my $template = read_file($path);
    #print "template: $template\n";
    $self->{template_file} = $file;
    $self->{template_string} = $template;
    $self->{template_path} = $path;
    $self->{token_hash} = {};
    $log->add_entry("Template: loaded template from file $path.\n",0);
  }
  else {
    $log->add_entry("Template: cannot find template file \'$path\'.\n");
    $self = 0;
  }
  return $self;
}

sub get_template_file_name($) {
  my $self = shift;
  return $self->{template_file};
}

sub set_token($$$) {
  my $self = shift;
  my $token_hash = $self->{token_hash};
  my $token = shift;
  my $value = shift;
  $token_hash->{$token} = $value;
  $self->_log_new_token($token);
}

sub set_tokens($$) {
  my $self = shift;
  my $new_tokens = shift;
  my $token_hash = $self->{token_hash};

  foreach my $token (%$new_tokens) {
    $token_hash->{$token} = $new_tokens->{$token};
    $self->_log_new_token($token);
  }
}

sub get_token($$) {
  my $self = shift;
  my $token = shift;
  return $self->{token_hash}->{$token};
  # print ("get_token - token: $token\n");
  # my $token_hash = $self->{token_hash};
  # my $value = $token_hash->{$token};
  # print ("get_token - token: $token; value: $value\n");
  # return $value;
}

sub get_tokens($) {
  my $self = shift;
  return $self->{token_hash};
}

sub get_processed_output($) {
  my $self = shift;
  $self->_process();
  return $self->{processed_results};
}

#
# Local methods
#
sub _process($) {
  my $self = shift;
  my $log = $self->{log};
  my $processed_template = $self->{template_string};
  my $token_hash = $self->{token_hash};

  foreach my $token (keys(%$token_hash)) {
    my $value = $self->_process_token($token);
    if ($value) {
      $processed_template =~ s/<%$token%>/$value/g;
    }
    else {
      $log->add_entry("Value not found for token $token; tags will be left unprocessed.\n");
    }
  }
  $self->{processed_results} = $processed_template;
}

sub _process_token($$) {
  my $self = shift;
  my $token = shift;
  my $log = $self->{log};
  my $raw_value = $self->get_token($token);
  my $value = '';

  my $type = ref($raw_value);
  if ($type) {
    $log->add_entry("Token $token is a ref to $type\n");
  }
  else {
    $log->add_entry("Token $token is not a ref\n");
    $value = $raw_value;
  }

  return $value;
}

sub _log_new_token($$) {
  my $self = shift;
  my $token = shift;
  my $log = $self->{log};
  $log->add_entry("Template: set value of \'$token\' to \'$self->{token_hash}->{$token}\'.\n",0);
}

1;
