#! /usr/bin/perl -w

use strict;
use Include;

use Auto::Base::HTML::Menu;
use Auto::Service;

my @fields = qw(name description months miles absolute);

if ($CGI_Obj->param('submit')
    && Auto::Service->validate({cgi => $CGI_Obj, tags => \%Template_Tags})) {
  my %args;
  foreach (@fields) {
    next unless $CGI_Obj->param($_);
    $args{$_} = $CGI_Obj->param($_);
  }
  Auto::Service->find_or_create(\%args);

  print $CGI_Obj->redirect($CFG{Scripts_URL} . 'dashboard.cgi');
}
else {
  page();
}

sub page {
  $Template_Tags{BODY} = read_file($CFG{Template_Dir} . "/service_create.html");
  $Template_Tags{MENU} = Auto::Base::HTML::Menu->getMenu();

  Auto::Car->populateForm({
    cgi    => $CGI_Obj,
    fields => \@fields,
    tags   => \%Template_Tags,
  });

  $Template_Tags{ABSOLUTE_CHECKED} = $CGI_Obj->param('absolute') ? 'CHECKED' : '';
  
  $Template_Obj->display();
}
