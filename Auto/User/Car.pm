package Auto::User::Car;
use base 'Auto::Base::HTML::Form';

__PACKAGE__->table('auto_user_car');
__PACKAGE__->columns(All => qw(id user_id car_id nickname mileage purchase_date
  sell_date));

__PACKAGE__->has_a(user_id => 'Auto::User');
__PACKAGE__->has_a(car_id  => 'Auto::Car');

__PACKAGE__->has_many(maintenances       => 'Auto::Maintenance');
__PACKAGE__->has_many(user_car_services  => 'Auto::User::Car::Service');

sub car  { return shift->car_id;  }
sub user { return shift->user_id; }

sub getUsersCarList {
  require Jundy::HTML::Select;

  my $self = shift;
  my $info_href = shift;

  my @values;
  my %labels;
  push(@values, '0');
  $labels{0} = 'Select A Car';
  
  my $itr = Auto::User::Car->search($info_href->{criteria});
  while (my $obj = $itr->next) {
    push(@values, $obj->id);
    $labels{$obj->id} = join(' - ', map { $obj->car->$_ } qw(make model year engine));
  }
  my $obj = Jundy::HTML::Select->new(
    name            => 'user_car_id',
    values          => \@values,
    visibles        => \%labels,
  );

  return $obj->get_select();
}

1;
