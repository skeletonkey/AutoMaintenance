#! /usr/bin/perl -w

use strict;
use Include;

use Auto::Base::HTML::Menu;
use Auto::User;

my @fields = qw(full_name email);

if ($CGI_Obj->param('submit') && validate()) {
  $CFG{_user}->set(
    email     => $CGI_Obj->param('email'),
    full_name => $CGI_Obj->param('full_name'),
  );
  $CFG{_user}->update;
  print $CGI_Obj->redirect($CFG{Scripts_URL} . 'dashboard.cgi');
}
else {
  page();
}

sub page {
  $Template_Tags{BODY} = read_file($CFG{Template_Dir} . "/account_update.html");
  $Template_Tags{MENU} = Auto::Base::HTML::Menu->getMenu();

  Auto::User::Car::Service->populateForm({
    cgi    => $CGI_Obj,
    data   => $CFG{_user}->asHashRef(),
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
  if (@missing) {
    $Template_Tags{ERROR} = 'Please provide the following: '
      . join(', ', @missing) . '<BR>';
    return 0;
  }
  else {
    my @errors;

    if (@errors) {
      $Template_Tags{ERROR} = join('<BR>', @errors);
      return 0;
    }
    else {
      return 1;
    }
  }
}
