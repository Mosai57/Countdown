use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;
use DBM::Deep;

use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (
	authors		=> '...',
	contact 	=> '...',
	name		=> '...',
	description 	=> '...',
	changed 	=> 'yyyy-mm-dd hh:mm (UTC-8:00)',
);

sub open_db {
    my $db_path = Irssi::get_irssi_dir . '/db/';
    -e $db_path or mkdir $db_path;
    my $db_file = $db_path . 'pats.db';
    my $db = new DBM::Deep(file => $db_file);      
    return $db;
}

sub pat{
	my ($server, $message, $nick, $address, $target) = @_;
	my $channel = $server->channel_find($target);
	my $pats_db = open_db();
	
	if($nick =~ /amiigo\|\d+/i){ return; }

	if($message =~ /^!pat \w+\s*$/i){

		$message =~ s/^!pat\s//;
		$message =~ s/\s+$//;

		if($channel->nick_find($message)){
			$server->command("ACTION $target pats " . $channel->nick_find($message)->{nick});
			$pats_db->{$target}{lc($message)}++;
		}else{
			$server->command("MSG $target I dont see that user here, therefore i cannot pat them.");
		}
	}
}

sub pet{
	my ($server, $message, $nick, $address, $target) = @_;
	my $channel = $server->channel_find($target);

	if($nick =~ /amiigo\|\d+/i){ return; }

	if($message =~ /^!pet \w+$/i){
		my (undef, $name) = split(' ', $message);
		if($channel->nick_find($name)){
			$server->command("ACTION $target pets $name");
		}
	}
}

sub pats{
	my ($server, $message, $nick, $address, $target) = @_;
	
	my $pats_db = open_db();

	if($nick =~ /amiigo\|\d+/i){ return; }

	if($message =~ /^!pats\s*\w*\s*$/i){		
		$message =~ s/^!pats\s*//;
		$message =~ s/\s*$//;

		if($pats_db->{$target}{lc($message)}){
			$server->command("MSG $target $message has recieved " . $pats_db->{$target}{$message} . " pats.");
		}elsif($message eq ""){
			$server->command("MSG $target $nick has recieved " . $pats_db->{$target}{$nick} . " pats");
		}else{
			$server->command("MSG $target I have no recorded pats for $message in $target.");
		}
	}
}

signal_add('message public', \&pat);
signal_add('message public', \&pet);
signal_add('message public', \&pats);