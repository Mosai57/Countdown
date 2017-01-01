use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;
use Games::Dissociate;

use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (
	authors		=> '...',
	contact 		=> '...',
	name		=> '...',
	description 	=> '...',
	changed 		=> 'yyyy-mm-dd hh:mm (UTC-8:00)',
);

Irssi::signal_add('message public', sub{
	my ($server, $message, $nick, $address, $target) = @_;

	if($message =~ /^!mopress\s*$/){
		my $chatnet = $server->{chatnet};
		open(my $fh, "<", "/home/moberry/logs/$chatnet/$channel" . ".log" );
		$server->command("MSG $target " . dissociate($fh));
	}

}
