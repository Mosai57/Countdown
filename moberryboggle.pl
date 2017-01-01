use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;

use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (
	authors			=> 'Jaykob Ross',
	contact 		=> 'mosai57@gmail.com',
	name			=> 'Boggle',
	description 	=> 'Boggle game designed for IRC use.',
	changed 		=> '2013-12-21 02:31 (UTC-8:00)',
);

#Boggle letters
my @dice = (
	['A','A','E','E','G','N'],
	['E','L','R','T','T','Y'],
	['A','O','O','T','T','W'],
	['A','B','B','J','O','O'],
	['E','H','R','T','V','W'],
	['C','I','M','O','T','U'],
	['D','I','S','T','T','Y'],
	['E','I','O','S','S','T'],
	['D','E','L','R','V','Y'],
	['A','C','H','O','P','S'],
	['H','I','M','N','Q','U'],
	['E','E','I','N','S','U'],
	['E','E','G','H','N','W'],
	['A','F','F','K','P','S'],
	['H','L','N','N','R','Z'],
	['D','E','I','L','R','X'],
);

my %ignore =(
	"Mesril"	=> 1,
	"Eldora"	=> 1,
	"sugarass"	=> 1,
	"Droplet"	=> 1,
	"Camazotz"	=> 1,
);

sub boggle{
	my ($server, $message, $nick, $address, $target) = @_;
	my $a = '';
	{ no warnings 'uninitialized'; return if ($ignore{$nick} == 1); }

	if($nick =~ /amiigo\|\d+/i){ return; }

	if($message =~ m/^!boggle$/i){
		for(my $i = 0; $i < 16; $i++){
			my $randNum = int(rand(6));
			$a .= @dice->[$i][$randNum] . " ";
		}
		$server->command("MSG $target $a");
	}
}

signal_add('message public', 'boggle');