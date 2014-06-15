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
  my $file_name_root = shift;
  my $self = new BaseObject();
  bless($self, $class);
  if ($self->_init($file_name_root)) {
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

  # Remove an extension from the provided name
  # and store the result to make log purging easier
  $file_name =~ s/\.\w*//;
  $self->{file_name_root} = $file_name;

  # Use the cwd as the file folder.
  my $file_folder = cwd();

  # Get a timestamp and remove any characters which
  # should not appear in file names.
  my $ts = get_time_stamp();
  $ts =~ tr/[ :]/[_\-]/;

  # Create the final file name by appending the
  # timestamp and a log extension to the root;
  $file_name .= "_$ts.log";
  #$file_name =~ s/:/-/g;

  # Generate the full path to file.
  my $file_path = $file_folder.'/'.$file_name;

  # Now try to open the log file
  my $fh;
  if (open($fh,">$file_path")) {
    # Save the file handle for the file.
    $self->{file_handle} = $fh;

    # Save all the pieces of the file path to
    # make purging log files easier.
    $self->{file_folder} = $file_folder;

    $self->{file_name} = $file_name;
    $self->{file_path} = $file_path;

    # Log the fact that the log was opened. Since it's obvious
    # it's open this is more to register the time.
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

# This method will purge log file created by this class
# in the same location where this instance was opened.
# This can be run anytime after the current log is created,
# even after it has been closed, as long as the Log object
# remains referenced.
# 0: self
# 1: number of log files to keep (including the currently open
#    one, if there is one.)
# r: number of log files that were deleted, or -1 if there was
#    an error (the error will be logged).
sub purge_log_files($$) {
  my $self = shift;
  my $keep_count = shift;
  my $deleted_count = 0;
  # Get the folder name and the root used for the file name
  my $folder = $self->{file_folder};
  my $file_name_root = $self->{file_name_root};

  # Now open the folder
  if (opendir(FOLDER, $folder)) {
    my @full_folder_list = readdir(FOLDER);
    closedir(FOLDER);
    $self->add_entry("Purging all $file_name_root log files before the newest $keep_count\n",0);
    my @sorted = reverse(sort(@full_folder_list));

    my $left_count = 0;
    foreach my $file (@sorted) {
      #next if $file =~ /\.{1,2}/;  # skip . and ..
      #next if $file !~ /.log$/;    # skip if the filename doesn't end in '.log'
      # skip if it doesn't matech our log names
      next if $file !~ /^$file_name_root.*\.log$/;

      # It's one of ours. Decide whether to keep it or not
      if ($left_count < $keep_count) {
        # Skip the 1st keep_count files
        #print "Keeping $file\n";
        $left_count++;
        next;
      }
      else {
        # Delete all the older ones and keep count
        #print "Deleting $file\n";
        unlink($folder.'/'.$file);
        $deleted_count++
      }
    }
  }
  else {
    $self->add_entry("Log->purge_log_files: Failed to open the log folder; Error $!\n");
    $deleted_count = -1;
  }

  return $deleted_count;
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
