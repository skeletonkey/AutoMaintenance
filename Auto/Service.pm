package Auto::Service;
use base 'Auto::Base::HTML::Form';

__PACKAGE__->table('auto_service');
__PACKAGE__->columns(All => qw(id name description months miles absolute));

__PACKAGE__->has_many(maintenances => 'Auto::Maintenance');
__PACKAGE__->has_many(user_car_services => 'Auto::User::Car::Service');

sub validate_definitions {
  return {
    description => { optional => 1 },
    months      => { re => '^\d+$', },
    miles       => { re => '^\d+$', },
    absolute    => { re => '^[01]$', default => 0},
  };
};

1;
