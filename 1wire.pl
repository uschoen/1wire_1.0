#!/usr/bin/perl -w 
$| = 1;

use strict;
use warnings;
use Getopt::Long qw(GetOptions);
use Data::Dumper;
use lib "/usr/local/etc/1WireToHM/modul";
use Gateways::Raspberry::wired1;

our $LOG;    				# Globale Logging
our %SYS=();   				# Globale Konfiguration

my $configFile="/usr/local/etc/1WireToHM/conf/1wire.xml";
my $daemon="false";

GetOptions('configfile=s' => \$configFile,
			"daemon=s"   => \$daemon)
or die "Usage: $0 --configfile\n";

	%SYS = %{(&readconfig($configFile))};
	if ($daemon){
		$SYS{'daemon'}=$daemon;
	}

if ( $SYS{daemon} eq "true" ) {
	my $pidFile= '/var/run/1WireToHM.pid';
	use POSIX;
	POSIX::setsid or die "setsid: $!";
	my $pid = fork ();
	if ($pid < 0) {
	die "fork: $!";
   	} elsif ($pid) {
   		open PIDFILE, ">$pidFile" or die "can´t open $pidFile: $!\n";
   		print PIDFILE $pid;
   		close PIDFILE;
		exit 0;
	}
$SIG{TERM} = sub { exit(0);};
   chdir "/";
   umask 0;
   foreach (0 .. (POSIX::sysconf (&POSIX::_SC_OPEN_MAX) || 1024))
      { POSIX::close $_ }
   open (STDIN, "</dev/null");
   open (STDOUT, ">/dev/null");
   open (STDERR, ">&STDOUT");
   $SIG{PIPE}='IGNORE';
}





####### add logging
if ( exists( $SYS{"logging"} ) ) {
    if (!($LOG =&createLogging($SYS{"logging"})))
   {
    print "can not create logging\n";
     exit(0);
    }
}
&log("info","start up easyHMC with PID " . $$ );



my %args=%{$SYS{'wired_temp'}{'config'}};
$args{'log'}=$LOG;

&log("info","start up easyHMC with PID " . $$ );
my $modul=new Gateways::Raspberry::wired1(%args); 

$modul->startup();

#######################################################
sub log
#	Version 3.0
#	Change 30.06.2012
#######################################################
{
	my $logdata->{'level'}=lc(shift ||"unkown");
	$logdata->{'msg'}=shift	||"unkown msg";
	($logdata->{'package'},$logdata->{'filename'},$logdata->{'line'}) = caller;
	if ($LOG)
	{   
		$LOG->write($logdata);
	}
	return 0;	
}
#################################################################
sub daemonize
#
#
#################################################################
{

}
###################################
sub readconfig
###################################
{
	my $file=shift;
	my $config="";
	my $cfg="";
	
	use XML::Simple;
	my $xml=XML::Simple->new();
	
	if ($cfg = eval {$xml->XMLin($file)}){
		my $config=formatConfig($cfg);
		return $config;
	}	
	print "error, cant not read config file " . $file . "\n";
    exit(0);
}
###################################
sub formatConfig
###################################
{
	my $cfg=shift;
	my $config;
	
	use Sys::Hostname;
	$config->{'system_name'} = hostname;
	
	$config = { %$config, %$cfg };
	if ( exists( $cfg->{'servers'}->{ $config->{'system_name'} } ) ) {
    	my $temp = $cfg->{'servers'}->{ $config->{'system_name'} };
    	$config = { %$config, %$temp };
    	if (
       		exists( $cfg->{'servers'}->{ $config->{'system_name'} }->{'logging'} ) )
    		{
       			$temp = $cfg->{'servers'}->{ $config->{'system_name'} }->{'logging'};
       			$config = { %$config, %$temp };
    		}
	}
	return $config;
}
###################################
sub createLogging
###################################
{
	my $config=shift;
	
	if (!($config)){
		print "get no config for logging\n";
		return 0;
	}
	if (!(exists($config->{'output'}))){
		print "no output for logging\n";
		return 0;	
	}
	use MultiLogger::Dispatcher;
	use MultiLogger::File;
	use MultiLogger::Console;
	use Time::HiRes qw(gettimeofday);
	
	my $logger=MultiLogger::Dispatcher->new();
	$config->{'msgformat'}=sub {
						my %p = @_;
						(my $seconds, my $microseconds) = gettimeofday;
						my @dta=gmtime($seconds);
						$dta[5]+=1900;
						$dta[4]++;
						$dta[2]=$dta[2]+1;
						my $pid=$$;
						my $string=sprintf("%04d.%02d.%02s %02d:%02d:%02d.%06d %-8s %6d %s\n",$dta[5],$dta[4],$dta[3],$dta[2],$dta[1],$dta[0],$microseconds,$p{'level'},$pid,$p{'message'});
						return $string; 
	};
	my %outputs=%{$config->{'output'}};
	my $output;
	
	foreach $output ( keys %outputs){
		if (ref($outputs{$output}) eq "ARRAY"){
			### more than fon outouts
			#print "error not jet, more then one output typ\n";
			my @outputs2=@{$outputs{$output}};
			foreach my $output2 (@outputs2){
				my $loglevel="";
				my $configOutput=$output2;
				if (!(exists($configOutput->{'loglevel'}))){
					$loglevel=$config->{'loglevel'};
				}else{
					$loglevel=$configOutput->{'loglevel'};
				}
				$configOutput->{'msgformat'}=$config->{'msgformat'};
				if (exists($configOutput->{'enable'})){
					if ($configOutput->{'enable'} ne "true"){
						next;
					}
				}
				### file
				if ($output eq "file"){
					$logger->add(MultiLogger::File->new($configOutput),$loglevel);
					next;
				}
				### console
				if ($output eq "console"){
					$logger->add(MultiLogger::Console->new($configOutput),$loglevel);
					next;
				}
				print "error unkown logging typ ($output), please check config\n";
			}
			
		}else{
			### one output
			my $loglevel="";
			my $configOutput=$outputs{$output};
			if (!(exists($configOutput->{'loglevel'}))){
				$loglevel=$config->{'loglevel'};
			}else{
				$loglevel=$configOutput->{'loglevel'};
			}
			$configOutput->{'msgformat'}=$config->{'msgformat'};
		
			### file
			if ($output eq "file"){
				$logger->add(MultiLogger::File->new($configOutput),$loglevel);
				next;
			}
			### console
			if ($output eq "console"){
				$logger->add(MultiLogger::Console->new($configOutput),$loglevel);
				next;
			}
			print "error unkown logging typ ($output), please check config\n";
		}
	}
	return $logger;
}
1;