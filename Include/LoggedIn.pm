  use File::Slurp;
  use lib '/home/jundy/modules', '/home/jundy/cgi-bin/configs';
package Include::LoggedIn;
#use parent 'Include';

use strict;

if (1) { #### SHOULD BE IN INCLUDE

  use Auto::Config::DB;
  our %CFG = (
    Scripts_URL  => $Auto::Config::Scripts_URL,
      Template_Dir => $Auto::Config::Template_Dir,
      );

  use Auto::Config::DB;
}

our @ISA = qw( Exporter );
our @EXPORT = qw(%CFG $CGI $Session $Template_Obj %Template_Tags);

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Session '-ip_match';
use Jundy::Template::Text::CGI;

use Auto::User;

our %CFG;
our $CGI = CGI->new;

our $Session = CGI::Session->new('driver:mysql', undef,
  {
    TableName => 'auto_sessions',
    Handle    => Auto::User->db_Main,
  }
);
if ($CGI->param('remember') || $Session->param('remember')) {
  $Session->param(remember => 1);
  $Session->expire('1w');
}
else {
  $Session->expire('1h');
}

if ($Session->param('user_id')) {
  if ($ENV{SCRIPT_NAME} =~ /login\.cgi$/ && $CGI->param('logout')) {
    $Session->delete;
    $Session->flush;
    print $CGI->redirect($CFG{Scripts_URL} . '/login.cgi');
    exit;
  }
  else {
    my @users = Auto::User->search(id => $Session->param('user_id'), active => 1);
    if ($users[0]) {
      $CFG{_user} = $users[0];
    }
    else {
      $Session->delete;
      $Session->flush;
      print $CGI->redirect($CFG{Scripts_URL} . '/login.cgi');
      exit;
    }
  }
}

if (!$CFG{_user}) {
  if (exists $ENV{SCRIPT_NAME}) {
    if (   $ENV{SCRIPT_NAME} !~ /login\.cgi$/
        && $ENV{SCRIPT_NAME} !~ /account_create\.cgi$/) {
      print $CGI->redirect($CFG{Scripts_URL} . '/login.cgi');
      exit;
    }
  }
  else {
    die("Inproper environment found");
  }
}

# Create Template Object
our %Template_Tags = (
  SCRIPTS_URL => $CFG{Scripts_URL},
  USER_NAME   => ($CFG{_user} ? $CFG{_user}->name : 'Not Logged In'),
);
our $Template_Obj = Jundy::Template::Text::CGI->new(
  header             => $Session->header(),
  template_file_name => $CFG{Template_Dir} . '/main.html',
  template_tags      => \%Template_Tags,
);

# Set the PDA flag
if ($ENV{HTTP_X_WAP_PROFILE} && $ENV{HTTP_X_WAP_PROFILE} =~ /blackberry/i) {
  $CFG{_PDA} = 'BB';
}
else {
  $CFG{_PDA} = '';
}

END {
  $Session->flush();
}

1;
