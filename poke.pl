use strict;
use Irssi qw/signal_add get_irssi_dir/;
use Irssi::Irc;
use warnings;

use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (
  authors		=> 'Jaykob Ross',
  contact 		=> 'Mosai57@gmail.com',
  name			=> 'poke',
  description 	        => 'Reacts to actions directed at the user.',
  changed 		=> 'yyyy-mm-dd hh:mm (UTC-8:00)',
);

my %ignore = (
  	"Mesril"	=> 1,
  	"Eldora"	=> 1,
  	"sugarass"	=> 1,
  	"Droplet"	=> 1,
  	"Camazotz"	=> 1,
);

my @verb = (
  	"smacks",
  	"hits",
  	"whacks",
  	"whops",
  	"assaults",
  	"strikes",
);

my @adj = (
  	"happy",
  	"sad",
  	"giant",
  	"tiny",
  	"colorful",
);

my @obj = (
  	"leek",
  	"brick",
  	"squeaky hammer",
  	"scissor sword",
  	"corgi",
  	"vocaloid",
  	"pikachu",
  	"tank",
  	"frying pan",
  	"vacuum",
  	"battleship",
  	"sandwich",
  	"chocolate chip muffin",
	"gas powered stick",
  	"panda",
	"Rule Breaker",
	"Friendmaker",
);

sub poke{
  	my($server, $arguments, $nick, $address, $target) = @_;

  	{ no warnings 'uninitialized'; return if ($ignore{$nick} == 1); }

	if($nick =~ /amiigo\|\d+/i){ return; }

  	my $me = $server->{nick};

  	if($arguments =~ /\S $me('s|\s|\w+|$)/i) {
    		return if $arguments =~ /unrelated/i;
    		$server->command("DESCRIBE $target $verb[int(rand(scalar(@verb)))] $nick with a $adj[int(rand(scalar(@adj)))] $obj[int(rand(scalar(@obj)))]");
  	}
}

sub mimic_droplet{
	my($server, $arguments, $nick, $address, $target) = @_;
	my $me = $server->{nick};

	{ no warnings 'uninitialized'; return if ($ignore{$nick} == 1); }

	if($nick =~ /amiigo\|\d+/i){ return; }

	if($arguments =~ /\S $me('s|\s|\w+|$)/i) {
		$arguments =~ s/^$nick //ig;
		$arguments =~ s/\b$me\b/$nick/ig;

		$server->command("ACTION $target $arguments");
	}
}

sub explode{
	my($server, $arguments, $nick, $address, $target) = @_;

  	{ no warnings 'uninitialized'; return if ($ignore{$nick} == 1); }
	
	if($nick =~ /amiigo\|\d+/i){ return; }

	my $me = $server->{nick};

	if($arguments =~ /\be?xp(eldo|lod)es?\b/i){
		my $aisle = int(rand(15))+1;
		$server->command("MSG $target CLEANUP ON AISLE $aisle!");
	}
}

signal_add('ctcp action', \&poke);
#signal_add('ctcp action', \&mimic_droplet);
signal_add('ctcp action', \&explode);