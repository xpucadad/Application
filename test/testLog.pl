use strict;
use warnings;

use lib '../lib';

use Log;

sub failure_exit($);

my $log = new Log($0);

if (!$log) {
  print "Cannot continue without a log.\n";
  failure_exit(-1);
}

printf ("Log opened at %s\n",$log->get_file_path());
$log->add_entry("This should appear in the log and on the console\n");
$log->add_entry("This should appear in both places\n",1);
$log->add_entry("This should appear only in the log\n",0);

$log->close();

exit(0);

sub failure_exit($) {
  my $status = shift;
  my $log = get_log();
  if ($log) {
    $log->add_entry("Failure exit with status $status\n");
    $log->close();
  }
  exit($status);
}
