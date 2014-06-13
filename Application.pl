# Template application with logging and property file handling.
#
use strict;
use warnings;

use lib './lib';

# project objects
use Log;
use ApplicationProperties;

#
# ToDo: add argument processing
#

my $log = new Log($0);

my $log_file_path = $log->get_file_path();
print "Log was created in file $log_file_path\n";
my $deleted_count = $log->purge_log_files(10);
$log->add_entry("$deleted_count old log files deleted\n");

$log->add_entry("This is an entry in the log.\n");

my $properties = new ApplicationProperties();

$log->close();

exit(0);
