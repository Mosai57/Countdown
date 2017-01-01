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

my $n = 1;

Irssi::signal_add('message public', sub{
	my ($server, $message, $nick, $address, $target) = @_;
	
	if($nick =~ /amiigo\|\d+/i){ return; }

	if($message =~ /^buh$/i && $n < 3){
		#$server->command("MSG $target $n");
		$n++;
	} elsif($message =~ /^buh$/i && $n == 3){
		$server->command("MSG $target buh");
		$n = 1;
	} else{
		$n = 1;
	}
});