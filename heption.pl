use strict;
use Irssi qw/signal_add get_irssi_dir/;
use Irssi::Irc;
use warnings;

use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (
	authors			=> 'Jaykob Ross',
	contact 		=> 'mosai57@gmail.com',
	name			=> 'Heption',
	description 		=> 'Personality script for the irc bot Heption',
	created 		=> '2015-03-15, 01:31 (-8 UTC)',
);

my $cooldown_timer = 0;

my @strings = (
	"I am Histoire, an infobot creatd by Mosai.",
	"My one and only directive is to provide information on the other bots in the channel.",
	"For any further information, please use !help.",
	"slinks back into the shadows"
);

my @smash_strings = (
	"DID SOMEONE SAY SMASH?!?!",
	"https://www.youtube.com/watch?v=And-vdjC71E",
	"CMON AND SMASH!"
);

my @response_strings = (
	"stares blankly",
	"blinks",
	"coughs",
	"looks away",
	"continues to read her books"
);

my @hits_comp = (
	"hits",
	"pokes",
	"smacks",
	"whacks",
	"strikes",
);

my @hits_resp = (
	"hits",
	"pokes",
	"strikes",
);

sub main{
	my ($server, $message, $nick, $address, $target) = @_;
	my $me = $server->{nick};

	if($message =~ /^who is histoire\??/i){
		for(my $i = 0; $i < 3; $i++){
			$server->command("MSG $target " . $strings[$i]);
		}
		$server->command("ACTION $target " . $strings[3]);
	}
}

sub smack_brad{
	my ($server, $message, $nick, $address, $target) = @_;
	
	if($nick =~ /bre?ad/i && $message =~ /(^|\s+)\bwelcome back\b(\s+|$)/i){
		$server->command("ACTION $target smacks $nick");
	}
}

sub smash{
	my ($server, $message, $nick, $address, $target) = @_;
	
	if($message =~ /\bsmash\b/i){
		if(time > $cooldown_timer + 1024){
			$server->command("MSG $target " . $smash_strings[int(rand(scalar(@smash_strings)))]);
			$cooldown_timer = time;
		}
	}
}

sub action{
	my($server, $arguments, $nick, $address, $target) = @_;
	my $me = $server->{nick};

	if($arguments =~ /$me/i && !($arguments ~~ @hits_comp)){
		$server->command("ACTION $target " . $response_strings[int(rand(scalar(@response_strings)))]);
	}elsif($arguments =~ /$me/i && $arguments ~~ @hits_comp){
		$server->command("ACTION $target " . $hits_resp[int(rand(scalar(@hits_resp)))]);
	}
}

sub theyre_action_figures{
	my ($server, $message, $nick, $address, $target) = @_;
	my $me = $server->{nick};
	
	if($message =~ /$me\b \b(plays with|collects)\b \b(figur(in)?es?|toys)\b/i){
		if(int(rand(scalar(4))) == 0){
			 $server->command("MSG $target ! THEYRE ACTION FIGURES!");
		}
	}
}

signal_add('message public', \&main);
#signal_add('message public', \&smack_brad);
#signal_add('message public', \&smash);
signal_add('ctcp action', \&action);
signal_add('message public', \&theyre_action_figures);
