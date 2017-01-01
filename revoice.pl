use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;

use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (
	authors		=> '...',
	contact 		=> '...',
	name		=> '...',
	description 	=> '...',
	changed 		=> 'yyyy-mm-dd hh:mm (UTC-8:00)',
);

my @names_to_voice = (
	"Eldora",
	"sugarass",
	"Moberry",
	"Heption",
	"Droplet",
);

sub revoice{
	my($server, $target, $nick, $address) = @_;

	return if $target ne "#induljharder";

	if( $nick ~~ @names_to_voice ){
		$server->command("/mode $target +v $nick");
	}
}

signal_add('message join', \&revoice);
