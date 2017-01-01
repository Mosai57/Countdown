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

my @ignore_list = (
	"moberry",
	"histy",
	"droplet",
	"diesis",
	"mesril",
	"dragonflame",
	"sugarass",
);

Irssi::signal_add('message public', sub{
	my ($server, $message, $nick, $address, $target) = @_;
	
	my $me = $server->{nick};
	
	if($message =~ /\b$me\W?/ig && !(lc( $nick ) ~~ @ignore_list ) ){
		Irssi::print "You were mentioned in $target by $nick at " . scalar(localtime());
	}
});
