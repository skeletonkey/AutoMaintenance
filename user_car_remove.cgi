#! /usr/bin/perl -w

use strict;
use Include::LoggedIn;

use Auto::Base::HTML::Menu;
use Auto::Car;
use Auto::User::Car;

my @fields = ('car_id');
if ($CGI->param('submit') && validate()) {
  my $user_car = Auto::User::Car->retrieve(car_id  => $CGI->param('car_id'),
    user_id => $CFG{_user}->id,
  ) || die("Auto::User::Car not found (" . $CGI->param('car_id') . '|' . $CFG{_user}->id . ")\n");

  $user_car->sell_date($CGI->param('sell_date'));
  $user_car->update;
    
  print $CGI->redirect($CFG{Scripts_URL} . 'dashboard.cgi');
}
else {
  page();
}

sub page {
  my @date_data = localtime();
  my $sell_date = join('-', ($date_data[5] + 1900), ($date_data[4] + 1),
    $date_data[3]);
  $Template_Tags{BODY} = read_file($CFG{Template_Dir} . "/user_car_remove.html");
  $Template_Tags{SELL_DATE} = $CGI->param('sell_date') || $sell_date;
  $Template_Tags{CARS_LIST} = Auto::Car->getList({
    default => $CGI->param('car_id') || 0,
    user_id => $CFG{_user}->id,
  });
  $Template_Tags{MENU} = Auto::Base::HTML::Menu->getMenu();
  
  $Template_Obj->display();
}

sub validate {
  my @missing;
  foreach (@fields) {
    push(@missing, ucfirst $_) unless $CGI->param($_);
  }
  $Template_Tags{ERROR} = 'Please provide the following: '
    . join(', ', @missing) . '<BR>' if @missing;

  return $Template_Tags{ERROR} ? 0 : 1;
}
