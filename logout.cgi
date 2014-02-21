#! /usr/bin/perl -w

use strict;
use Include;

$Session->delete();
print $CGI_Obj->redirect($CFG{Scripts_URL} . '/login.cgi');
