#! /usr/bin/perl -w

use strict;
use Include::LoggedIn;

use Auto::User;

my @fields = qw(name password full_name email confirm_password);

if ($CGI->param('submit') && validate()) {
  my %args = (active => 1);
  $args{$_} = $CGI->param($_) for @fields;
  delete $args{confirm_password};

  my $user = Auto::User->create(\%args);
  $user->set_password($args{password});

  $Session->param('user_id', $user->id);

  print $CGI->redirect($CFG{Scripts_URL} . 'dashboard.cgi');
}
else {
  page();
}

sub page {
  $Template_Tags{BODY} = read_file($CFG{Template_Dir} . "/account_create.html");

  Auto::Car->populateForm({
    cgi    => $CGI,
    fields => \@fields,
    tags   => \%Template_Tags,
  });
  
  $Template_Obj->display();
}

sub validate {
  my @errors;
  my @missing;
  foreach (@fields) {
    push(@missing, $_) unless $CGI->param($_);
  }
  push(@errors, 'Please provide the following: ' . join(', ', @missing))
    if @missing;

  push(@errors, 'Password does not match')
    unless $CGI->param('password') eq $CGI->param('confirm_password');

  push(@errors, 'Username unavailable')
    if Auto::User->new_name_not_uniq(0, $CGI->param('name'));

  $Template_Tags{ERROR} = join('<BR>', @errors);

  return $Template_Tags{ERROR} ? 0 : 1;
}
