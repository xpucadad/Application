package Failfast;
#
# This is the Failfast object
#
# Still to add:
# - stack dump
# Workflow:
#  Main creates a new Failfast object, passing in the script name ($0)
#  Main calls 'script_is_locked'. If locked, this will not return, but will
#    exit with a status of -98. User will need to delete the lock file
#    (instructions will be provided) and then rerun the script.
#  Once created, the object can be retrieved from anywhere using the function
#    get_failfast();
#  Any method or function can retrieve the object with get_failfast, and then
#    call the exec method. This will log the message, create the lock file,
#    close the log and exit with a status of -99.
#
BEGIN {
  use Exporter;
  @ISA = qw(Exporter);
  @EXPORT = qw(failfast);
}

use strict;
use warnings;

use base qw(BaseObject);

# Project objects
use Log;

# Perl modules
use Cwd;

# Constructor.
# If the contructor is call a second time it just returns the failfast object.
# 0: class
# 1: script name (used to create a unique lock object)
# r: the new Failfast object; 0 if the object
#    creation fails for any reason.
sub new($$) {
  my $class = shift;
  my $script_name = shift;
  my $self;
  our $failfast;
  if ($failfast) {
    $self = $failfast;
    my $log = $self->{log};
    $log->add_entry("WARNING Failfast::new: The failfast object already exits and has been returned without modification.\n");
  }
  else {
    $self = new BaseObject();
    bless($self, $class);
    $self->init($script_name);
    $failfast = $self;
  }
  return $self;

}

sub init($$) {
  my $self = shift;
  my $script_name = shift;
  print "script name: $script_name\n";
  my $cwd = cwd();
  print "cwd: $cwd\n";
  my $lock_file_name = $script_name;
  $lock_file_name =~ s/^([^\.]+)\.\w*/$1/;
  $lock_file_name .= '.lock';
  print "lock file name: $lock_file_name\n";
  my $lock_file_path = $cwd.'/'.$lock_file_name;
  print "lock file path: $lock_file_path\n";
  $self->{lock_file_path} = $lock_file_path;
  return $self;
}

sub script_is_locked($) {
  my $self = shift;
  my $path = $self->{lock_file_path};
  if (-e $path?1:0) {
    my $log = $self->{log};
    $log->add_entry("Script is locked. Exitting with status -98\n");
    exit(-98);
  }
  else {
    return 0;
  }
}

sub exec($$) {
  my $self = shift;
  my $message = shift;
  my $log = $self->{log};
  $log->add_entry($message);
  $self->_create_lock_file();
  $log->add_entry("Exitting with status -99\n");
  $log->close();
  exit(-99);
}

sub _create_lock_file($) {
  my $self = shift;
  my $path = $self->{lock_file_path};
  my $log = $self->{log};
  if (open(LOCK,">$path")) {
    close(LOCK);
    $log->add_entry("Failfast lock file $path created.\n");
  }
  else {
    $log->add_entry("ERROR Failfast::failfast: Failed to create lock file $path. Error: $!\n");
  }
}



# functions (not methods)
sub failfast($) {
  my $message = "Failfast was called\n";
  $message = shift if @_;
  our $failfast;
  if (!$failfast) {
    my $log = get_log();
    $log->add_entry("ERROR Failfast::failfast: No Failfast object was created!\n");
    $log->add_entry("ERROR Failfast::failfast: Will create generic lock file\n");

    $failfast = new Failfast("failfast_generic");
  }
  $failfast->exec($message);
}

BEGIN {
  our $failfast = 0;
}

1;
