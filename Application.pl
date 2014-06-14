# Template application with logging and property file handling.
#
use strict;
use warnings;

use lib './lib';

# project objects
use Log;
use ApplicationProperties;
use ApplicationUtilities;

#
# ToDo: add argument processing
#

# Create a new logging object. Use the script
# name as the root for the log file name. (The
# Log constructor will strip the the '.pl'.)
my $log = new Log($0);

# Put the log file path on the console
my $log_file_path = $log->get_file_path();
print "Log was created in file $log_file_path\n";

# Now delete all log files except for the 10 newest
# ones. Since our new log file has been created, it
# and the 9 next most recent will be kept.
# For interest log the number of log files deleted.
my $deleted_count = $log->purge_log_files(10);
$log->add_entry("$deleted_count old log files deleted\n");

# Load properties for the application.
my $properties = new ApplicationProperties();

# Just for kicks, dump the properties
$log->add_entry("These properties were loaded from")

# Do some application work and log it.
$log->add_entry("This is an entry in the log.\n");

# Close he log and exit with 0 as success
$log->close();
exit(0);
