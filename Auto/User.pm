package Auto::User;
use base 'Auto::Base::DB';

use Crypt::CBC;

__PACKAGE__->table('auto_user');
__PACKAGE__->columns(All => qw(id name password full_name email active));

__PACKAGE__->has_many(cars => 'Auto::User::Car', 'user_id');

__PACKAGE__->add_constructor(new_user_name_uniq => ' id != ? and user_name = ? ');

{
  my $_password_key = 'This is the tracker key';
  sub check_password {
    my $self = shift;
    my $password = shift;
    return $password eq $self->password;
  
    my $cipher = Crypt::CBC->new(-key => $_password_key);
    return $self->password eq $cipher->encrypt($password) ? 1 : 0;
  }

  sub set_password {
    my $self = shift;
    my $password = shift;

    $self->password($password);
    $self->update;
    return 1;
    my $cipher = Crypt::CBC->new(-key => $_password_key);
    return $cipher->encrypt($password);
  }
}


1;
