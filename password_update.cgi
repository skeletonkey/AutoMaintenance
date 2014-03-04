#! /usr/bin/perl -w

use strict;
use Include::LoggedIn;

use Auto::Base::HTML::Menu;
use Auto::User;

my @fields = qw(new_password current_password confirm_password);

if ($CGI->param('submit') && validate()) {
  $CFG{_user}->set_password($CGI->param('new_password'));
  print $CGI->redirect($CFG{Scripts_URL} . 'dashboard.cgi');
}
else {
  page();
}

sub page {
  $Template_Tags{BODY} = read_file($CFG{Template_Dir} . "/password_update.html");
  $Template_Tags{MENU} = Auto::Base::HTML::Menu->getMenu();

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

    push(@errors, 'New password can not be the same as your current password')
      if $CGI->param('current_password') eq $CGI->param('new_password');

    push(@errors, 'New password did not match the confirmation')
      if $CGI->param('new_password') ne $CGI->param('confirm_password');

    if (@errors) {
      $Template_Tags{ERROR} = join('<BR>', @errors);
      return 0;
    }
    else {
      return 1;
    }
  }
}
