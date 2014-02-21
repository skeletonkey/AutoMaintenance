package Auto::Session;
use base 'Auto::Base:DB';

__PACKAGE__->table('auto_sessions');
__PACKAGE__->columns(All => qw(id a_session));

1;
