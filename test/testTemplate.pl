# test the Properties object
use strict;
use warnings;

use lib qw(./lib ../lib);

use Template;
use Log;
use ApplicationUtilities;

my $log = new Log($0);

my $template = new Template('xtestTemplate.html');
if (!$template) {
  failure_exit();
}

my $result = $template->get_processed_output();

print "$result";

exit(0);
