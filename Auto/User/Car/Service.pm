package Auto::User::Car::Service;
use base 'Auto::Base::DB';
use base 'Auto::Base::HTML::Form';

__PACKAGE__->table('auto_user_car_service');
__PACKAGE__->columns(All => qw(id user_car_id service_id));

__PACKAGE__->has_a(user_car_id => 'Auto::User::Car');
__PACKAGE__->has_a(service_id  => 'Auto::Service');

sub user_car { return shift->user_car_id; }
sub service  { return shift->service_id;  }

sub needed {
  my $class = shift;
  my $user_car_id = shift;

  require Auto::Maintenance;

  my @needed;
  foreach my $user_car_service ($class->search(user_car_id => $user_car_id)) {
    my ($maint) = Auto::Maintenance->search(
      user_car_id => $user_car_service->user_car_id,
      service_id  => $user_car_service->service_id,
      { order_by => 'mileage' }
    );

    my $maint_mileage = $maint ? $maint->mileage : 0;
    if ($user_car_service->user_car->mileage - $maint_mileage >= $user_car_service->service->miles) {
      push(@needed, $user_car_service);
    }
  }

  return @needed;
}

sub getCarsServiceList {
  require Jundy::HTML::Select;

  my $self = shift;
  my $info_href = shift;

  my @values;
  my %labels;
  push(@values, '0');
  $labels{0} = 'Select A Service';

  my $itr = Auto::User::Car::Service->search($info_href->{criteria});
  while (my $obj = $itr->next) {
    push(@values, $obj->id);
    $labels{$obj->id} = join(' - ', map { $obj->service->$_ } qw(name description));
  }
  my $obj = Jundy::HTML::Select->new(
    name            => 'user_car_service_id',
    values          => \@values,
    visibles        => \%labels,
  );

  return $obj->get_select();
}

1;
