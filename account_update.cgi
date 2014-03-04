#! /usr/bin/perl -w

use strict;
use Include::LoggedIn;

use Auto::Base::HTML::Menu;
use Auto::User;

my @fields = qw(full_name email);

if ($CGI->param('submit') && validate()) {
  $CFG{_user}->set(
    email     => $CGI->param('email'),
    full_name => $CGI->param('full_name'),
  );
  $CFG{_user}->update;
  print $CGI->redirect($CFG{Scripts_URL} . 'dashboard.cgi');
}
else {
  page();
}

sub page {
  $Template_Tags{BODY} = read_file($CFG{Template_Dir} . "/account_update.html");
  $Template_Tags{MENU} = Auto::Base::HTML::Menu->getMenu();

  Auto::User::Car::Service->populateForm({
    cgi    => $CGI,
    data   => $CFG{_user}->asHashRef(),
    fields => \@fields,
    tags   => \%Template_Tags,
  });

  $Template_Obj->display();
}

sub validate {
  my @missing;
  foreach (@fields) {
    push(@missing, $_) unless $CGI->param($_);
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
