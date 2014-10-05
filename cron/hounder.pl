#! /usr/bin/perl -ws

use strict;
use lib ('/home/jundy/cgi-bin/auto', '/home/jundy/cgi-bin/configs', '/home/jundy/modules');
use vars qw($D $v);

use MIME::Lite;

use Include;

use Auto::User;
use Auto::User::Car::Service;

foreach my $user (Auto::User->search(active => 1)) {
  next unless $user->email;

  my $message = '';

  print "User: " . $user->name . "\n" if $v;
  foreach my $car ($user->cars(sell_date => undef)) {
    print "Car: " . $car->name . "\n" if $v;
    my @needed = Auto::User::Car::Service->needed($car->id);
    if (@needed) {
      $message .= $car->name . " has some overdue services: \n\t";
      $message .= join("\n\t", map({ $_->service->name } @needed)) . "\n\n";
    }
  }

  if ($message) {
    my $msg = MIME::Lite->new(
      Data    => $message,
      From    => $Auto::Config::Admin_Email,
      Subject => 'Auto Maintenance Reminder',
      To      => $user->email,
      Type    => 'text/plain',
    );
    $msg->send;
  }
}
