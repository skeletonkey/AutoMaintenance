#! /usr/bin/perl -w

use strict;
use Include;

use Auto::Car;

my @fields = qw(make model year engine);

if ($CGI_Obj->param('submit') && validate()) {
  my %args;
  $args{$_} = $CGI_Obj->param($_) for @fields;
  Auto::Car->find_or_create(\%args);
  print $CGI_Obj->redirect($CFG{Scripts_URL} . 'dashboard.cgi');
}
else {
  new_car_page();
}

sub new_car_page {
  $Template_Tags{BODY} = read_file($CFG{Template_Dir} . "/auto_create.html");
  Auto::Car->populateForm({
    cgi    => $CGI_Obj,
    fields => \@fields,
    tags   => \%Template_Tags,
  });
  
  $Template_Obj->display();
}

sub validate {
  my @missing;
  foreach (@fields) {
    push(@missing, $_) unless $CGI_Obj->param($_);
  }
  $Template_Tags{ERROR} = 'Please provide the following: '
    . join(', ', @missing) . '<BR>' if @missing;

  $Template_Tags{ERROR} .= 'Must provide a 4 digit year<BR>'
    unless $CGI_Obj->param('year') =~ /^\d{1,4}$/;

  return $Template_Tags{ERROR} ? 0 : 1;
}
