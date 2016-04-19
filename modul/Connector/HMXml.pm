#!/usr/bin/perl -w
$| = 1;

package Connector::HMXml;
@ISA = qw(Connector::DefaultConnector);
use strict;
use warnings;
use Data::Dumper;  


use constant true => 1;
use constant false => 0;

#######################################################
sub new
#	Vars=%config
#	
#
#######################################################
{
	my $class=shift;
	my $arg_hash = (ref($_[0]) eq 'HASH') ? $_[0] : {@_};
	
	if (!($_[0])){
		print "no args given\n\r";
		return;
	}
	
	my $self={};
	bless $self,$class;
	$self->init_args($arg_hash);
	return $self;
}  
####################################################### 
sub init_args
#	
#
#######################################################
{
	my $self= shift;
	my $ARGS_ref= shift;
	my %ARGS=%{$ARGS_ref};
	
	$self->{'log'}=(exists($ARGS{'log'})) ? $ARGS{'log'} : '';
	$self->{'hm_url'}=(exists($ARGS{'hm_url'})) ? $ARGS{'hm_url'} : 'http://192.168.3.90/config/xmlapi/statechange.cgi';
	$self->log("info","Connector HMXML build complete");	
}
####################################################### 
sub sendData
#	
#
#######################################################
{
	my $self= shift;
	my $ise_id=shift;
	my $value=shift;
	
	use LWP::Simple;
 
	my $url=  $self->{'hm_url'}."?ise_id=".$ise_id."&new_value=".$value;
	$self->log("debug","send:".$url);
	my $content = get($url);
 
	$self->log("debug","answer:".$content);
}
