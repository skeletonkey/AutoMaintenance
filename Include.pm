use File::Slurp;
use lib '/home/jundy/modules', '/home/jundy/cgi-bin/configs';

package Include;

use strict;

our @ISA = qw( Exporter );
our @EXPORT = qw( %CFG );

use Auto::Config::DB;

our %CFG = (
  Scripts_URL  => $Auto::Config::Scripts_URL,
  Template_Dir => $Auto::Config::Template_Dir,
);

1;
