package ArrayToken;
# This object represents a token whose value is an array where each entry
# in the area represests a list entry or a row in a table.
# When processed, the line after the token is used to create an output line for
# each entry (except the first) in the ArrayToken.
use strict;
use warnings;

use base qw(Token);

sub new($$$) {
  my $class = shift;
  my $name = shift;
  my $value = shift;
  my $self = new Token($name);
  bless($self, $class);
  return $self->init($value);
}

sub init($$) {
  my $self = shift;
  my $value_array = shift;
  my $delimiter = shift(@$value_array);

  $self->{delimiter} = $delimiter;
  $self->{value_array} = $value_array;

  return $self;
}

# Get the final value of the token by creating the rows for the table
# 0: self
# 1: template line
sub get_value($$) {
  my $self = shift;
  my $template = shift;
  my $value = '';
  my $delimiter = $self->{delimiter};
  my @rows = @{$self->{value_array}};
  for (my $i=0;$i<@rows;$i++) {
    # get the column values for this row
    my $row = $rows[$i];
    my @columns = split($delimiter, $row);

    # Put the original row in [0] for debugging
    unshift(@columns, $row);

    # Get a fresh copy of the template
    my $line = $template;

    # Replace the column tokens with the column values. Column tokens are
    # in the form <%i%>, where i is a number from 0 to size of the array.
    for (my $j=0; $j<@columns; $j++) {
      $line =~ s/<%$j%>/$columns[$j]/g;
    }

    # Add this line to the value
    $value .= $line;
  }

  $self->{value} = $value;
  return $self->{value};
}

# Processes all the values in the token into lines based on the token's tag in
# the template.
sub process($$) {
  my $self = shift;
  my $context = shift;

  my $template_line = $context->{to_process};

  print "template_line: $template_line\n";
  # We want the result to be processed for other tokens so we put the result
  # in to_process and return an empty value
  $context->{to_process} = $self->get_value($template_line);

  return '';
}

1;
