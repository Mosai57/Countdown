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
	changed 		=> '10/13/2015',
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
	my ($shc, $date, $reg_name) = @_;
	my $db = open_db();
	$db->{$shc}->{date} = $date;
	$db->{$shc}->{nick} = $reg_name;
}

sub delete_event
{
	my $shc = shift;
	my $db = open_db();
	delete $db->{$shc};
}

sub mod_event
{
	my ($shc, $new_date) = @_;
	my $db = open_db();
	$db->{$shc}->{date} = $new_date;
}

## Processing Functions ###

sub generate_output
{
	my ($shc, $date) = @_;
	
	# If the database entry expiry date is older than the current date.
	if($date < time())
	{
		delete_event($shc);
		return "$shc occured on " . scalar(localtime($date));
	}
	
	# Hit only if the shc passed to the function is unique.
	my $cdn = $date - time();
	
	my $days 	= floor($cdn / 86400);
	my $hours 	= ($cdn / 3600) % 24;
	my $minutes 	= ($cdn / 60) % 60;
	my $seconds 	= ($cdn) % 60;
	
	my $string = "$shc: ";
	$string .= format_string($days, $hours, $minutes, $seconds);
	
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
	my $timestamp = str2time($date);
	return $timestamp
}

### Frontend Commands ###

sub add_event_frontend
{
	my ($server, $message, $nick, $address, $target) = @_;

	if($message =~ /^!addcdn\s*(\w+)\s*(\S.*\S)$/i)
	{
		my ($shc, $date) = ($1, $2);
        $shc = lc $shc;
		my $db = open_db();
        
        my $message;
        
        my $when = create_timestamp($date);
        if (!defined $when) {
            $message = 'Invalid date';
        } elsif (exists $db->{$shc}) {
            $message = 'A countdown with that same name already exists.';
        } else {
            add_event($shc, $when, lc($nick));
            $message = generate_output($shc, $when);
		}
        $server->command("MSG $target $message");
	}
}

sub search_event_frontend
{
	my ($server, $message, $nick, $address, $target) = @_;
	
	if($message =~  /^!cdn \w+$/i)
	{
		my (undef, $shc) = split(' ', $message);
		$shc = lc($shc); # Ensures that the shc will be found in the db if it exists. All SHCs in the db are lc.		

		my $db = open_db();
		if(exists $db->{$shc})
		{
			my $time = $db->{$shc}->{date};
			my $output = generate_output($shc, $time);
			$server->command("MSG $target $output");
		}
		else
		{
			$server->command("MSG $target The shc ( $shc ) does not exist.");
		}
	}
}

sub date_for_frontend
{
	my ($server, $message, $nick, $address, $target) = @_;
	
	if($message =~ /^!datefor\s*(\w+)$/i)
	{
		my ($shc) = ($1);
		$shc = lc($shc);
		
		my $db = open_db();
		if(exists $db->{$shc})
		{
			my $time = scalar(localtime($db->{$shc}->{date}));
			$time =~ s/\d{2}:\d{2}:\d{2} //;
			$server->command("MSG $target $shc: $time, registered by " . $db->{$shc}->{nick});
		}
		else
		{
			$server->command("MSG $target The cdn ( $shc ) does not exist.");
		}
	}
}

sub mod_date_frontend
{
	my ($server, $message, $nick, $address, $target) = @_;
	
	if($message =~ /^!moddate\s*(\w+)\s*(\S.*\S)/i)
	{
        my ($shc, $new_date) = ($1, $2);
		$shc = lc($shc);
		my $db = open_db();
        
        my $message;
		
        my $when = create_timestamp($new_date);
        if (!defined $when) {
            $message = 'Invalid date';
        } elsif (exists $db->{$shc} && $db->{$shc}{nick} ne lc($nick)) {
            $message = "You are not authorized to modify that cdn";
        } else {
            delete $db->{$shc};
            $_[1] =~ s/^!moddate/!addcdn/i;
            goto &add_event_frontend;
        }
        
        $server->command("MSG $target $message");
	}
}

sub del_event_frontend
{
	my ($server, $message, $nick, $address, $target) = @_;
	
	if($message =~ /^!(?:deldate|delcdn)\s*(\w+)$/i)
	{
		my ($shc) = ($1);
		$shc = lc($shc);
		my $db = open_db();
		
		if(exists $db->{$shc})
		{
			if($db->{$shc}->{nick} eq lc($nick))
			{
				delete_event($shc);
				$server->command("MSG $target The cdn $shc has been deleted.");
			}
		}
	}
}

signal_add('message public', \&add_event_frontend);
signal_add('message public', \&search_event_frontend);
signal_add('message public', \&date_for_frontend);
signal_add('message public', \&mod_date_frontend);
signal_add('message public', \&del_event_frontend);
