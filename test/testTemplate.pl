# test the Properties object
use strict;
use warnings;

use lib qw(./lib ../lib);

use Log;
use Failfast;
use ApplicationUtilities;
use Template qw(current_date current_time current_date_time);

sub returns_shit();

my $log = new Log($0);
$log->purge_log_files(10);
my $failfast = new Failfast($0);

my $template = new Template('testTemplate.html');
if (!$template) {
  failure_exit();
}

$template->set_token_value('name','Ken');
$template->set_token_value('years','35');
$template->set_token_value('shittalk', \&returns_shit);
$template->set_token_value('date', \&current_date);
$template->set_token_value('time', \&current_time);
$template->set_token_value('timestamp', \&current_date_time);

my @rows;
push(@rows,',');
push(@rows,'11,12,13');
push(@rows,'21,22,23');
push(@rows,'31,32,33');
$template->set_token_value('table_row',\@rows);

my $processed_content = $template->get_processed_output();

my $output_file_name = "processedTestTemplate.html";
open(OUT,">$output_file_name");
print OUT $processed_content;
close(OUT);

system("open $output_file_name");

success_exit();

sub returns_shit() {
  return 'shit';
}
