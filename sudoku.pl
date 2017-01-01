use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;
use Switch;

use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (
	authors		=> '...',
	contact 		=> '...',
	name		=> '...',
	description 	=> '...',
	changed 		=> 'yyyy-mm-dd hh:mm (UTC-8:00)',
);

sub sudoku{
	my ($server, $message, $nick, $address, $target) = @_;

	if($nick =~ /amiigo\|\d+/i){ return; }

	my $url = "http://www.websudoku.com/?level=";
	
	if($message =~ /^!sudoku$/i){

		$url = $url . (int(rand(4))+1);

		$server->command("MSG $target $url");
	}
}

signal_add('message public', \&sudoku);
