# test the Token objects
use strict;
use warnings;

use lib qw(./lib ../lib);

use Log;
use ApplicationUtilities;
use Tokens;
use ValueToken;

my $log = new Log($0);
$log->purge_log_files(10);

my $tokens = new Tokens();
$tokens->create_value_token("token_1", "value_1");

$tokens->dump_tokens();

success_exit();
