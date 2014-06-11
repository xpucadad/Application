use strict;
use warnings;

use lib '../lib';

use Log;

my $log = new Log($0);

$log->add_entry("This should appear in the log and on the console\n");
$log->add_entry("This should appear in both places\n",1);
$log->add_entry("This should appear only in the log\n",0);

$log->close();
