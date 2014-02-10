#! /usr/bin/perl -w

use strict;
use Include;

use Auto::Base::HTML::Menu;
use Auto::Car;
use Auto::User::Car;

my @fields = ('car_id');
if ($CGI_Obj->param('submit') && validate()) {
  Auto::User::Car->find_or_create({
    car_id  => $CGI_Obj->param('car_id'),
    user_id => $CFG{_user}->id,
  });
    
  print $CGI_Obj->redirect($CFG{Scripts_URL} . 'dashboard.cgi');
}
else {
  page();
}

sub page {
  $Template_Tags{BODY} = read_file($CFG{Template_Dir} . "/user_car_create.html");
  $Template_Tags{CARS_LIST} = Auto::Car->getList({
    default => $CGI_Obj->param('car_id') || 0,
  });
  $Template_Tags{MENU} = Auto::Base::HTML::Menu->getMenu();
  
  $Template_Obj->display();
}

sub validate {
  my @missing;
  foreach (@fields) {
    push(@missing, ucfirst $_) unless $CGI_Obj->param($_);
  }
  $Template_Tags{ERROR} = 'Please provide the following: '
    . join(', ', @missing) . '<BR>' if @missing;

  return $Template_Tags{ERROR} ? 0 : 1;
}
