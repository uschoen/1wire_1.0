#!/usr/bin/perl -w
$| = 1;

package DefaultClass;

use strict;
use warnings;
use Data::Dumper;  

use constant true => 1;
use constant false => 0;
our $AUTOLOAD;
####################################################### 
sub DESTROY
#	
#
#######################################################
{
	my $self= shift;
	
	$self->log("info", ref($self)." shutdown");
}
####################################################### 
sub log
#	
#
#######################################################
{
	my $self= shift;
	my $logdata->{'level'}=lc(shift ||"unkown");
	$logdata->{'msg'}=shift	||"unkown msg";
	if (!($self->{'log'})){
		#######
		print $logdata->{'msg'}."\n";
		#######
		return;
	}
	($logdata->{'package'},$logdata->{'filename'},$logdata->{'line'}) = caller;
	$logdata->{'package'}=ref($self);
	$self->{'log'}->write($logdata);
	return 0;	
}
#######################################################
sub new
#	Vars=%config
#	{'log_object'}=Instants zum loggen
#
#######################################################
{
	my $class=shift;
	my $arg_hash = (ref($_[0]) eq 'HASH') ? $_[0] : {@_};
	
	
	my $self={};
	bless $self,$class;
	
	
	my %ARGS=%{$arg_hash};
	$self->{'log'}=(exists($ARGS{'log'})) ? $ARGS{'log'} : '';
	
	$self->init($arg_hash);
	
	$self->log("info",ref($self)." object create");
	return $self;
}
#######################################################
#
sub init
#
#######################################################
{
	my $self=shift;
	$self->log("debug",ref($self)." no init implemet");
}
####################################################### 
sub AUTOLOAD
#	
#
#######################################################
{
      my $self = shift;
      $self->log("warning","calling sub: ".$AUTOLOAD." not fond");
      return (false);
}
1;