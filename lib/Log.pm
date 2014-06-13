package Log;

# The Log objects supports logging to a file. Each entry may be
# optinally printed to the console.
#
# There can be only one log object open at a time. If you need more
# you can derive a class from this object for each seperate log you
# need.
#
BEGIN {
  use Exporter;
  @ISA = qw(Exporter);
  @EXPORT = qw(get_log get_time_stamp);
}

use strict;
use warnings;
use base qw(BaseObject);

# Perl modules
use Cwd;

# Construtor
# Creates a new log file in the pwd. The name is generated
# by removing any '.' and extension, appending '_' followed
# by a time stamp (without spaces) and terminated with '.log'
# The resulting Log object is also store in the singleton
# our $log. It can be retrieved using the get_log function
# (not method). The full file path is stored in the hash
# and keyed by "file_path". It can be retrieved with the
# get_file_path method.
#
# 0: class
# 1: script name (usually - can be any string)
# ret: the newly created Log object or 0 if the
#     construction fails for any reason.
#
sub new($$) {
  my $class = shift;
  my $script_name = shift;
  my $self = new BaseObject();
  bless($self, $class);
  $script_name =~ s/\.\w*//;
  if ($self->_init($script_name)) {
    our $log = $self;
  }
  else {
    $self = 0;
  }
  return $self;
}

# Internal method to inialize the object.
# 0: self
# 1: the filename portion of arugment passed to the
#    construtor.
# r: the initialized Log object or 0 if there was
#    any problem inializing the object
sub _init($$) {
  my $self = shift;
  my $file_name = shift;
  my $ts = get_time_stamp();
  $file_name .= " $ts.log";
  $file_name =~ s/ /_/g;
  $file_name =~ s/:/-/g;

  # Try to open the log file
  my $fh;
  my $file_path = cwd().'/'.$file_name;
  if (open($fh,">$file_path")) {
    $self->{file_handle} = $fh;
    $self->{file_name} = $file_name;
    $self->{file_path} = $file_path;

    $self->add_entry("Log file opened in:\n",0);
    $self->add_entry("\t$file_path\n",0);
  }
  else {
    print "Failed to open log file at $file_path. Error: $!\n";
    $self = 0;
  }

  return $self;
}

# Method to add a message to the log file and optionally
# print it on the console.
# 0: self
# 1: the message (a \n must be explicitly passed if you
#    want it).
# 2: print to console (option; default 1):
#    0 => don't print the message to the console
#    1 => (default) also print the message to the console
# r: return the Log object to allow calls to be chained.
sub add_entry($$;$) {
  my $self = shift;
  my $message = shift;
  my $print_to_console = 1;
  if (@_ > 0) {
    $print_to_console = shift;
  }
  my $fh = $self->{file_handle};
  my $time_stamp = get_time_stamp();
  my $full_msg = $time_stamp.' '.$message;
  print $fh $full_msg;
  print $full_msg if $print_to_console;
  return $self;
}

# Closes the log file if it's open. After closing
# the object cannot be used and get_log will return 0.
# 0: self
# r: none
sub close($) {
  my $self = shift;
  my $fh = $self->{file_handle};
  if ($fh) {
    $self->add_entry("Log file closed.\n",0);
    close($fh);
    $self->{file_handle} = 0;
    our $log = 0;
  }
}

# Destructor; it just calls the close method.
sub DESTROY($) {
  my $self = shift;
  $self->close();
}

# Returns the (full) file path for the log file.
# 0: self
# r: the full file path of the log file starting at '/'
sub get_file_path($) {
  my $self = shift;
  return $self->{file_path};
}

# functions

# this function returns the Log object stored in the log singleton.
sub get_log() {
  return our $log;
}

# Generates and returns a time stamp.
sub get_time_stamp() {
  my ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
  my $ts = sprintf("%4d-%02d-%02d %02d:%02d:%02d",
          $year + 1900, $mon + 1, $mday,
          $hour, $min, $sec);
  return $ts;
}

# Set up our script-wide storage.
BEGIN {
  # A singleton to store the Log object.
  our $log = 0;
}

1;
