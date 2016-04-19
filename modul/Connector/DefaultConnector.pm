#!/usr/bin/perl -w
$| = 1;

package Connector::DefaultConnector;

@ISA = qw(DefaultClass);
use strict;
use warnings;
use Data::Dumper;  

use constant true => 1;
use constant false => 0;
our $AUTOLOAD;
####################################################### 
sub sendData
#	
#
#######################################################
{
	my $self= shift;
	
	$self->log("error", ref($self)." no sendData methode found");	
}
1;