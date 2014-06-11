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

$log->add_entry("This is an entry in the log.\n");

my $properties = new ApplicationProperties();

$log->close();

exit(0);
