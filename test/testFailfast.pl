# test the Failfast object
use strict;
use warnings;

use lib qw(./lib ../lib);

use Log;
use Failfast;

my $log = new Log($0);

my $failfast = new Failfast($0);

if ($failfast->script_is_locked()) {
  $log->add_entry("Script is locked!\n");
}
else {
  $log->add_entry("Script wasn't locked!\n");
}

my $test = failfast("Called using function\n");

exit(0);
