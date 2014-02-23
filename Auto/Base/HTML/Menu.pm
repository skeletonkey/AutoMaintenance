package Auto::Base::HTML::Menu;
use parent 'Auto::Base';

my @files = (
  '/auto/js/nav.js',
);
my @menu = (
  {
    title => 'Dashboard',
    link  => "dashboard.cgi",
  },
  {
    title => 'Cars',
    link  => '#',
    menu  => [
      {
        title => 'Create New',
        link  => "auto_create.cgi",
      },
      {
        title => 'Add to Account',
        link  => "user_car_create.cgi",
      },
    ],
  },
  {
    title => 'Service',
    link  => '#',
    menu  => [
      {
        title => 'List',
        link  => "dashboard.cgi?list=service",
      },
      {
        title => 'Create New',
        link  => "service_create.cgi",
      },
      {
        title => 'Add to Car',
        link  => "user_car_service_create.cgi",
      },
    ],
  },
  {
    title => 'Account',
    link  => '#',
    menu  => [
      {
        title => 'Update Info',
        link  => "account_update.cgi",
      },
      {
        title => 'Update Password',
        link  => "password_update.cgi",
      },
      {
        title => 'Logout',
        link  => "login.cgi?logout=1",
      },
    ],
  },
);

sub getHeader {
  my $header = '';
  $header .= "<script src='$_'></script>" for @files;
  return $header;
}

sub getMenu {
  my $menu = q+<div class='navigation'>+;
  
  $menu .= q+<ul class='nav'>+;
  $menu .= _get_menu($_) for @menu;
  $menu .= '</ul>';

  return $menu;
}

sub _get_menu {
  my $data = shift;

  my $menu = '<li><a href="' . $data->{link} . '">' . $data->{title} . '</a>';

  if ($data->{menu}) {
    $menu .= '<ul>';
    $menu .= _get_menu($_) for @{$data->{menu}};
    $menu .= '</ul>';
  }

  $menu .= '</li>';
  return $menu;
}

1;
