package Auto::Car;
use parent 'Auto::Base::DB';
use parent 'Auto::Base::HTML::Form';

__PACKAGE__->table('auto_car');
__PACKAGE__->columns(All => qw(id make model year engine));

__PACKAGE__->has_many(user_cars => 'Auto::User::Car', 'car_id');

sub getList {
  my $self = shift;
  my $args = shift;

  $args->{default_visible} ||= 'Select Car';
  $args->{id_field}        ||= 'id';
  $args->{name}            ||= 'car_id';
  $args->{name_field}      ||= sub {
    my $obj = shift;
    return join(' - ', map { $obj->$_ } qw(make model year engine));
  };
  $args->{order_by}        ||= 'model, make, year';

  return $self->SUPER::getList($args);
}

1;
