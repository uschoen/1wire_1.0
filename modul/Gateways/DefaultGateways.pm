#!/usr/bin/perl -w
$| = 1;

package Gateways::DefaultGateways;

@ISA = qw(DefaultClass);
use strict;
use warnings;
use Data::Dumper;  

use constant true => 1;
use constant false => 0;
our $AUTOLOAD;
####################################################### 
sub startup
#	
#
#######################################################
{
	my $self= shift;
	
	$self->log("info", ref($self)." no run methode found");	
}
1;