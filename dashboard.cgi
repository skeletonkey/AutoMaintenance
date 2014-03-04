#! /usr/bin/perl -w

use strict;
use Include::LoggedIn;

use HTML::Table;

use Auto::Base::HTML::Menu;
use Auto::Service;
use Auto::User::Car::Service;

dashboard();

sub dashboard {
  $Template_Tags{BODY} = read_file($CFG{Template_Dir} . "/dashboard.html");
  $Template_Tags{CARS} = get_cars();
  $Template_Tags{LIST} = get_list($CGI->param('list'));
  $Template_Tags{MENU} = Auto::Base::HTML::Menu->getMenu();
  
  $Template_Obj->display();
}

sub get_list {
  my $list = shift || return '';

  my $tbl = HTML::Table->new;
  if ($list eq 'service') {
    $tbl->addRow(qw(Name Description Months Miles Absolute));
    my $itr = Auto::Service->retrieve_all;
    while (my $service = $itr->next) {
      $tbl->addRow(map { $service->$_ } qw(name description months miles absolute));
    }
  }
  return $tbl->getTable;
}

sub get_cars {
  my $ret;
  foreach my $user_car (Auto::User::Car->search(user_id => $CFG{_user}->id)) {
    my $car = $user_car->car;
    my $tbl = HTML::Table->new();
    $tbl->addRow(join(' - ', $car->make, $car->model, $car->year, $car->engine) . ' [' . $user_car->mileage . ']');
    $tbl->addRow(sprintf('<a href="%s?user_car_id=%d">Enter Maintenance</a>',
      $CFG{Scripts_URL} . '/maintenance_add.cgi', $user_car->id));
    $tbl->addRow('Done On', 'Mileage', 'Type');
    foreach my $car_service (Auto::User::Car::Service->needed($user_car->id)) {
      $tbl->addRow('NEEDED', undef, $car_service->service->name);
      $tbl->setCellClass($tbl->getTableRows, 1, 'note');
    }
    foreach my $maint ($user_car->maintenances) {
      $tbl->addRow($maint->done_on, $maint->mileage, $maint->service->name);
    }
    $tbl->setCellColSpan(1, 1, $tbl->getTableCols);
    $tbl->setCellColSpan(2, 1, $tbl->getTableCols);
    $ret .= $tbl->getTable;
  }

  return $ret;
}
