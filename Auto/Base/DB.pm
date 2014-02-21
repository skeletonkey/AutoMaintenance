package Auto::Base::DB;
use base 'Auto::Base';
use base 'Class::DBI';

Auto::Base::DB->connection(
  'dbi:mysql:' . $Auto::Config::DB::Database,
  $Auto::Config::DB::Database_User,
  $Auto::Config::DB::Database_Password
);

sub asHashRef {
  my $self = shift;

  my $href;
  $href->{$_} = $self->get($_) for $self->columns;

  return $href;
}

1;
