use strict;
use Irssi qw/signal_add get_irssi_dir/;
use Irssi::Irc;
use warnings;
use utf8;
use File::Slurp;

use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (
	authors			=> 'Jaykob Ross',
	contact 		=> 'mosai57@gmail.com',
	name			=> 'Heption',
	description 		=> 'Personality script for the irc bot Heption',
	created 		=> '2015-03-15, 01:31 (-8 UTC)',
);

my @emotes = (
	"(-_-;)",
	"( T^T)",
	"(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧",
	"ಠ_ಠ",
	"*\\(^w^)/*",	
);

my $last_emote;

sub return_emote{
	my ($server, $message, $nick, $address, $target) = @_;
	
	return if $nick =~ (/^amiigo\|\d+/);

	if ($message =~ /^!histy$/i){
		my $emote = $emotes[int(rand(scalar(@emotes)))];
		$server->command("MSG $target $emote");
	}
}

signal_add('message public', \&return_emote);
	
	
