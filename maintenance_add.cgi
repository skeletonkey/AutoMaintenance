#! /usr/bin/perl -w

use strict;
use Include;

use Auto::Base::HTML::Menu;
use Auto::Maintenance;
use Auto::Service;
use Auto::User::Car;

my @fields = grep { $_ ne 'id' } Auto::Maintenance->columns;

Auto::User::Car->authorize($CGI_Obj, {
  id      => $CGI_Obj->param('user_car_id'),
  user_id => $CFG{_user}->id,
});

if ($CGI_Obj->param('user_car_service_id')) {
  my $ucs = Auto::User::Car::Service->retrieve($CGI_Obj->param('user_car_service_id'));
  $CGI_Obj->param(
    -name  => 'service_id',
    -value => $ucs->service_id,
  );
}

if ($CGI_Obj->param('submit') && Auto::Maintenance->validate({ cgi => $CGI_Obj, tags => \%Template_Tags })) {
  my $user_car_service = Auto::User::Car::Service->retrieve($CGI_Obj->param('user_car_service_id'));
  Auto::Maintenance->find_or_create({
    done_on     => $CGI_Obj->param('done_on'),
    mileage     => $CGI_Obj->param('mileage'),
    service_id  => $user_car_service->service_id,
    user_car_id => $CGI_Obj->param('user_car_id'),
  });

  print $CGI_Obj->redirect($CFG{Scripts_URL} . 'dashboard.cgi');
}
else {
  maintenance_add();
}

sub maintenance_add {
  my $user_car = Auto::User::Car->retrieve($CGI_Obj->param('user_car_id'));

  $Template_Tags{SERVICE_LIST} = Auto::User::Car::Service->getCarsServiceList({
    criteria => { user_car_id => $CGI_Obj->param('user_car_id'), },
  });

  $Template_Tags{BODY} = read_file($CFG{Template_Dir} . "/maintenance_add.html");
  $Template_Tags{MENU} = Auto::Base::HTML::Menu->getMenu();

  Auto::User::Car::Service->populateForm({
    cgi    => $CGI_Obj,
    fields => \@fields,
    tags   => \%Template_Tags,
  });
  
  $Template_Obj->display();
}

