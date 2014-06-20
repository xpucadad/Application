# test the Failfast object
use strict;
use warnings;

use lib qw(./lib ../lib);

use Log;
use Failfast;

my $log = new Log($0);
$log->purge_log_files(10);

my $failfast = new Failfast($0);

if ($failfast->script_is_locked()) {
  $log->add_entry("Script is locked!\n");
}
else {
  $log->add_entry("Script wasn't locked!\n");
}

#my $test = failfast("Failfast requested using failfast() function.\n");
my $test = $failfast->exec("Failfast requested using exec() method.\n");

exit(0);
