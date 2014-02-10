#! /usr/bin/perl -w

use strict;
use Include;

use Auto::Base::HTML::Menu;
use Auto::Car;
use Auto::Service;
use Auto::User::Car::Service;

my @fields = ('user_car_id', 'service_id');
if ($CGI_Obj->param('submit') && Auto::User::Car::Service->validate({cgi => $CGI_Obj, tags => \%Template_Tags})) {
  Auto::User::Car->authorize($CGI_Obj, {
    user_id => $CFG{_user}->id,
    car_id  => $CGI_Obj->param('car_id'),
  });
  Auto::User::Car::Service->find_or_create({
    user_car_id => $CGI_Obj->param('user_car_id'),
    service_id  => $_,
  }) for $CGI_Obj->param('service_id');
  print $CGI_Obj->redirect($CFG{Scripts_URL} . 'dashboard.cgi');
}
else {
  page();
}

sub page {
  $Template_Tags{BODY} = read_file($CFG{Template_Dir} . "/user_car_service_create.html");
  $Template_Tags{MENU} = Auto::Base::HTML::Menu->getMenu();

  $Template_Tags{CARS_LIST} = Auto::User::Car->getUsersCarList({
    criteria => { user_id => $CFG{_user}->id },
  });
  my %data;
  my $itr = Auto::Service->retrieve_all;
  while (my $obj = $itr->next) {
    push(@{$data{values}}, $obj->id);
    $data{labels}{$obj->id} = join(' - ', map { $obj->$_ } qw(name description months miles absolute));
  }
  $Template_Tags{SERVICES} = $CGI_Obj->checkbox_group(
    -name      => 'service_id',
    -linebreak => 'true',
    -values    => $data{values},
    -labels    => $data{labels},
  );
  
  $Template_Obj->display();
}
