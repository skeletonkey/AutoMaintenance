#! /usr/bin/perl -w

use strict;
use Include::LoggedIn;

use Auto::User;

if ($CGI->param('login')) {
  my @user = Auto::User->search(name => $CGI->param('user_name'));
  if ($user[0] && $user[0]->check_password($CGI->param('password'))) {
    $Session->param('user_id', $user[0]->id);
    print $CGI->redirect($CFG{Scripts_URL} . 'dashboard.cgi');
  }
  else {
    $Template_Tags{WARNINGS} = 'Invalid Login';
    login_page();
  }
}
else {
  login_page();
}

sub login_page {
  #$Template_Tags{DATA} = Dumper($Session);
  $Template_Tags{USER_NAME} = $CGI->param('user_name') || '';
  $Template_Tags{PASSWORD} = $CGI->param('password') || '';
  $Template_Tags{BODY} = read_file($CFG{Template_Dir} . "login.html");
  
  $Template_Obj->display();
}
