# test the Properties object
use strict;
use warnings;

use lib qw(./lib ../lib);

use Template;
use Log;
use ApplicationUtilities;

my $log = new Log($0);

my $template = new Template('testTemplate.html');
if (!$template) {
  failure_exit();
}

$template->set_token('name','Sexy Hunk');
$template->set_token('years','35');

my $processed_content = $template->get_processed_output();

my $output_file_name = "processedTestTemplate.html";
open(OUT,">$output_file_name");
print OUT $processed_content;
close(OUT);

system("open $output_file_name");

exit(0);
