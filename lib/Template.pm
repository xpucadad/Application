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
  print "path: $path\n";
  if (-e $path) {
    my $template = read_file($path);
    print "template: $template\n";
    $self->{template} = $template;
    $self->{template_path} = $path;
  }
  else {
    $log->add_entry("Template: cannot find template file \'$path\'.\n");
    $self = 0;
  }
  return $self;
}

sub get_processed_output($) {
  my $self = shift;
  return $self->{template};
}

1;
