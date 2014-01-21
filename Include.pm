use File::Slurp;
use lib '/home/jundy/modules', '/home/jundy/cgi-bin/configs';

package Include;

use strict;

our @ISA = qw( Exporter );
our @EXPORT = qw(%CFG $CGI_Obj $Session $Template_Obj %Template_Tags);

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Session '-ip_match';
use Jundy::Template::Text::CGI;

use Auto::Config::DB;
use Auto::User;

our %CFG = (
  Scripts_URL  => $Auto::Config::Scripts_URL,
  Template_Dir => $Auto::Config::Template_Dir,
);

our $CGI_Obj = CGI->new();
our $Session = CGI::Session->new('driver:mysql', undef,
  {
    TableName => 'auto_sessions',
    Handle    => Auto::User->db_Main,
  }
);
$Session->expire('1w');

if ($Session->param('user_id')) {
  if ($ENV{SCRIPT_NAME} =~ /login\.cgi$/ && $CGI_Obj->param('logout')) {
    $Session->delete;
    $Session->flush;
    print $CGI_Obj->redirect($CFG{Scripts_URL} . '/login.cgi');
    exit;
  }
  else {
    $CFG{_user} = Auto::User->retrieve($Session->param('user_id'));
  }
}

if (!$CFG{_user}) {
  if ($ENV{SCRIPT_NAME} !~ /login\.cgi$/) {
    print $CGI_Obj->redirect($CFG{Scripts_URL} . '/login.cgi');
    exit;
  }
}

END {
  $Session->flush();
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

1;
