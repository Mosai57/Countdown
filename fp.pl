use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;
use DBM::Deep;

use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (
	authors			=> 'Jaykob Ross',
	contact 		=> 'Mosai@mosai57.com',
	name			=> 'Quotes',
	description 	=> 'Adds and returns quotes to and from a .dp file to irc channels.',
	created			=> '2015-08-03',
	changed 		=> '2015-08-03',
);

sub fp
{
	my ($server, $message, $nick, $address, $target) = @_;
	
	if($message =~ /^!furryporn\s*$/i)
	{
		$server->command("ACTION $target smacks $nick");
	}
}

signal_add('message public', \&fp);