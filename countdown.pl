use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;
use POSIX qw/floor/;
use Date::Parse;
use DBM::Deep;

use vars qw($VERSION %IRSSI);
$VERSION = "1";
%IRSSI = (
	authors			=> 'Jaykob Ross',
	contact 		=> 'Mosai@mosai57.com',
	name			=> 'Countdown',
	description 		=> 'Stores, returns, and calculates a countdown to a specified date.',
	created			=> '09/27/2015',
	changed 		=> '09/27/2015',
);

### Database Functions ###

sub open_db 
{
	my $db_path = Irssi::get_irssi_dir . '/db/';
	-e $db_path or mkdir $db_path;
	my $db_file = $db_path . 'events.db';
	my $db = new DBM::Deep(file => $db_file);      
	return $db;
}

sub add_event
{
	my ($shc, $date) = @_;
	my $db = open_db();
	$db->{$shc} = $date;
}

sub delete_event
{
	my $shc = shift;
	my $db = open_db();
	delete $db->shc;
}

## Processing Functions ###

sub generate_output
{
	my ($shc, $date) = @_;
	
	# If the database entry expiry date is older than the current date.
	if($date < time())
	{
		delete_event($shc);
		return "$shc occured on " . scalar(localtime($date)) . ", removing the shc from the database.";
	}
	
	# Hit only if the shc passed to the function has not expired.
	my $cdn = $date - time();
	
	my $days 	= floor($cdn / 86400);
	my $hours 	= ($cdn / 3600) % 24;
	my $minutes 	= ($cdn / 60) % 60;
	my $seconds 	= ($cdn) % 60;
	
	my $string = "$shc: " . format_string($days, $hours, $minutes, $seconds);
	
	return $string
}

sub format_string
{
	my ($days, $hours, $minutes, $seconds) = @_;
	my $formatted_string = "";
	
	# Big long string of if statements to generate a properly formatted string
	# The goal is to prevent any 0 entry numbers (0 Days, 0 Hours, 0 Minutes, etc...)
	# Due to the catch in the generate_output function before this function is called,
	# The string returned by this function is guaranteed to not be undefined.
	if($days > 0)
	{
		$formatted_string .= "$days Days ";
	}
	if($hours > 0)
	{
		$formatted_string .= "$hours Hours ";
	}
	if($minutes > 0)
	{
		$formatted_string .= "$minutes Minutes ";
	}
	if($seconds > 0)
	{
		$formatted_string .= "$seconds Seconds";
	}
	
	return $formatted_string;
}

sub create_timestamp
{
	my $date = shift;
	my $timestamp = str2time($date . " 00:00", "%s");
	return $timestamp
}

### Frontend Commands ###

sub add_event_frontend
{
	my ($server, $message, $nick, $address, $target) = @_;

	if($message =~ /^!addcdn \w+ (0[1-9]|1[0-2])\/(0[1-9]|1\d|2\d|3[01])\/(19|20)\d{2}$/i)
	{
		my (undef, $shc, $date) = split(' ', $message);
		my $db = open_db();
		
		if(!(exists $db->{$shc}))
		{
			add_event(lc($shc), create_timestamp($date));
			$server->command("MSG $target Countdown saved.");
		}
	}
}

sub search_event_frontend
{
	my ($server, $message, $nick, $address, $target) = @_;
	
	if($message =~  /^!cdn \w+$/i)
	{
		my (undef, $shc) = split(' ', $message);
		
		my $db = open_db();
		if(exists $db->{$shc})
		{
			my $time = $db->{$shc};
			my $output = generate_output($shc, $time);
			$server->command("MSG $target $output");
		}
		else
		{
			$server->command("MSG $target The shc ( $shc ) does not yet exist.");
		}
	}
}

signal_add('message public', \&add_event_frontend);
signal_add('message public', \&search_event_frontend);
