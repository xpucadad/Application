package Log;

BEGIN {
  use Exporter;
  @ISA = qw(Exporter);
  @EXPORT = qw(get_log get_time_stamp);
}

use strict;
use warnings;
use base qw(BaseObject);

sub new($$) {
  my $class = shift;
  my $script_name = shift;
  my $self = new BaseObject();
  bless($self, $class);
  $script_name =~ s/\.\w*//;
  our $log = $self->init($script_name);
  return $self;
}

sub init($$) {
  my $self = shift;
  my $filename = shift;

  $filename .= '.log';

  my $fh;
  if (open($fh,">$filename")) {
    $self->{file_handle} = $fh;
    $self->add_entry("Log file opened.\n");
  }
  else {
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
