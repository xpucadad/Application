# test the Properties object
use strict;
use warnings;

use lib qw(./lib ../lib);

use Log;
use TestProperties;

my $log = new Log($0);

#new TestProperties();

$log->add_entry("Properties loaded as test properties:\n");
my $test_properties = get_test_properties();
foreach my $key (keys(%$test_properties)) {
  $log->add_entry("\t\'$key\': \'$test_properties->{$key}\'\n");
}

exit(0);
