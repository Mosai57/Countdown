use strict;
use Irssi qw/signal_add get_irssi_dir/;
use Irssi::Irc;
use warnings;

use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (
	authors			=> 'Jaykob Ross',
	contact 		=> 'Mosai57@gmail.com',
	name			=> 'Chatter',
	description 	=> 'IRC Quote script. Returns a random line from a provided log file.',
	changed 		=> 'yyyy-mm-dd hh:mm (UTC-8:00)',
);

my %botinfo = (
	"heption"	=>	'Wouldnt you like to know.',
	"droplet"	=>	'Droplet: !overlord, !mrwelch, !seen {name}, !beelab {equation}, !kjp, !zinit, !dcc',
	"moberry"	=>	'Moberry: !chatter, !spell {name}, !rlh, !rps, !rpsls',
	"eldora"	=>	'Eldora: !buh, !chioroll',
	"camazotz"	=>	'Camazotz: !roll {#d#}, !draw, !random {bot will give further info}',
	"mesril"	=>	'Mesril: !rroulette, !ddg {search term}',
);


sub help{
	my ($server, $message, $nick, $address, $target) = @_;
	my $me = $server->{nick};
	my $chanobj = $server->channel_find($target);
	my $lcme = lc($me);

	if($message =~ /^!help \w+$/i){
		my @mess = split(' ', $message);

		#my $search = $mess[1];

		$mess[1] = lc($mess[1]);

		if( exists( $botinfo{$mess[1]} ) && $chanobj->nick_find($mess[1]) ){
			$server->command("NOTICE $nick ! " . $botinfo{ $mess[1] } );
		} elsif( $mess[1] eq "all" ){
			my @bts = keys %botinfo;
			for my $bts (keys %botinfo){
				if($chanobj->nick_find($bts) && $bts ne $lcme){
					$server->command("NOTICE $nick ! " . $botinfo{$bts});
				}
			}
		} else{	$server->command("NOTICE $nick ! Error, cannot find that name in my list."); }
	} elsif($message =~ /^!help(\s+)?$/i){
		$server->command("NOTICE $nick ! Please search a bot by name.");
	}
}

signal_add('message public', \&help);