package Auto::Maintenance;
use parent 'Auto::Base::DB';

__PACKAGE__->table('auto_maintenance');
__PACKAGE__->columns(All => qw(id user_car_id service_id mileage done_on
  comments));

__PACKAGE__->has_a(service_id  => 'Auto::Service');
__PACKAGE__->has_a(user_car_id => 'Auto::User::Car');

__PACKAGE__->add_trigger(after_create => \&update_mileage);

sub service  { return shift->service_id;  }
sub user_car { return shift->user_car_id; }

sub validate_definitions {
  return {
    done_on    => { re => '^\d{4}-\d{2}-\d{2}$' },
    mileage    => { re => '^\d+$' },
    service_id => { re => '^\d+$' },
  };
}

sub update_mileage {
  my $self = shift;

  if ($self->mileage > $self->user_car->mileage) {
    $self->user_car->mileage($self->mileage);
    $self->user_car->update;
  }
}

1;
