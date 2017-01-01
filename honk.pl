use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;

use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (
	authors		=> 'Jaykob Ross',
	contact 	=> 'None, I prefer glasses',
	name		=> 'Honk',
	description 	=> '( ͡° ͜ʖ ͡°)',
);

sub honk {
	my ($server, $message, $nick, $address, $target) = @_;
	
	my $channel = $server->channel_find($target);
	my @users = @{[$channel->nicks]};
	
	if($message =~ /^!honk\s*$/ig){
		$server->command("ACTION $target honks " . $users[int(rand(scalar(@users)))]->{nick});
	}
}

signal_add('message public', \&honk);
