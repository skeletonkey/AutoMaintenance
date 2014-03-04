#! /usr/bin/perl -w

use strict;
use Include::LoggedIn;

use Auto::Base::HTML::Menu;
use Auto::Service;

my @fields = qw(name description months miles absolute);

if ($CGI->param('submit')
    && Auto::Service->validate({cgi => $CGI, tags => \%Template_Tags})) {
  my %args;
  foreach (@fields) {
    next unless $CGI->param($_);
    $args{$_} = $CGI->param($_);
  }
  Auto::Service->find_or_create(\%args);

  print $CGI->redirect($CFG{Scripts_URL} . 'dashboard.cgi');
}
else {
  page();
}

sub page {
  $Template_Tags{BODY} = read_file($CFG{Template_Dir} . "/service_create.html");
  $Template_Tags{MENU} = Auto::Base::HTML::Menu->getMenu();

  Auto::Car->populateForm({
    cgi    => $CGI,
    fields => \@fields,
    tags   => \%Template_Tags,
  });

  $Template_Tags{ABSOLUTE_CHECKED} = $CGI->param('absolute') ? 'CHECKED' : '';
  
  $Template_Obj->display();
}
