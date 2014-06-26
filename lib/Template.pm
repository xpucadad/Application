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
    if (open(TEMP, $path)) {
      my @template = <TEMP>;
      close(TEMP);
      $self->{template_file} = $file;
      $self->{template_array} = \@template;
      $self->{template_path} = $path;
      $self->{token_hash} = {};
      $log->add_entry("Template: loaded template from file $path.\n",0);
    }
    else {
      $log->add_entry("Template: failed to load template file $path; Error: $!\n");
      $self = 0;
    }
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
  my $processed_template;
  my $token_hash = $self->{token_hash};

  foreach my $line (@{$self->{template_array}}) {
    foreach my $token (keys(%$token_hash)) {
      if ($line =~ /^.*<%$token%>/) {
        my $value = $self->_process_token($token);
        if ($value) {
          $line =~ s/<%$token%>/$value/g;
        }
        else {
          $log->add_entry("Value not found for token $token; tags will be left unprocessed.\n");
        }
      }
    }
    $processed_template .= $line;
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
    $log->add_entry("Token $token is a ref to $type\n",0);
    if ($type eq 'CODE') {
      $value = &$raw_value();
    }
  }
  else {
    $log->add_entry("Token $token is not a ref\n",0);
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
