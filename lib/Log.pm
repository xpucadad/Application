package Log;

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

sub new($$) {
  my $class = shift;
  my $script_name = shift;
  my $self = new BaseObject();
  bless($self, $class);
  $script_name =~ s/\.\w*//;
  if ($self->init($script_name)) {
    our $log = $self;
  }
  else {
    $self = 0;
  }
  return $self;
}

sub init($$) {
  my $self = shift;
  my $file_name = shift;
  my $ts = get_time_stamp();
  $file_name .= " $ts.log";
  $file_name =~ s/ /_/g;

  # Try to open the log file
  my $fh;
  my $file_path = cwd().'/'.$file_name;
  if (open($fh,">$file_path")) {
    $self->{file_handle} = $fh;
    $self->{file_name} = $file_name;
    $self->{file_path} = $file_path;

    $self->add_entry("Log file opened in:\n");
    $self->add_entry("\t$file_path\n");
  }
  else {
    print "Failed to open log file at $file_path. Error: $!\n";
    $self = 0;
  }

  return $self;
}

sub add_entry($$) {
  my $self = shift;
  my $message = shift;
  my $fh = $self->{file_handle};
  my $time_stamp = get_time_stamp();
  print $fh $time_stamp.' '.$message;
}

sub close($) {
  my $self = shift;
  my $fh = $self->{file_handle};
  if ($fh) {
    $self->add_entry("Log file closed.\n");
    close($fh);
    $self->{file_handle} = 0;
  }
}

sub DESTROY($) {
  my $self = shift;
  $self->close();
}

# functions
sub get_log() {
  return our $log;
}

sub get_time_stamp() {
  my ($sec,$min,$hour,$mday,$mon,$year) = localtime(time);
  my $ts = sprintf("%4d-%02d-%02d %02d:%02d:%02d",
          $year + 1900, $mon + 1, $mday,
          $hour, $min, $sec);
  return $ts;
}

BEGIN {
  our $log = 0;
}

1;
