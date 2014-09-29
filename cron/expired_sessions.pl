#! /usr/bin/perl -ws

use strict;
use lib ('/home/jundy/cgi-bin/auto', '/home/jundy/cgi-bin/configs', '/home/jundy/modules');
use vars qw($D $v);

use Time::Local;
use Auto::Session;

$v ||= 0;
my $max_age = 60 * 60 * 24 * 7; #seconds
my $current_time = timelocal(localtime());

print("Max Age: $max_age\n") if $v;
foreach my $session (Auto::Session->retrieve_all) {
  my $data = eval  $session->a_session ;
  die('Eval error on sesson ' . $session->id . ': ' . $@) if $@;
  my $age = $current_time - $data->{_SESSION_ATIME};
  print $session->id . ' last accessed: ' . scalar(localtime($data->{_SESSION_ATIME})) . " (Age: $age)" if $v;
  if ($age > $max_age) {
    print " [DEL]" if $v;
    $session->delete;
  }
  print "\n" if $v;
}
