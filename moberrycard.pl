use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;
 
use vars qw($VERSION %IRSSI);
 
$VERSION = "1";
%IRSSI = (
        authors         => 'Mosai with improvements by Stevie-O',
        contact         => 'mosai57@gmail.com',
        name            => 'Cards',
        description     => 'Selects a random card or a specific one if predicted.',
        changed         => '2014-01-7 21:47 (UTC-8:00)',
);
 
my @suit = qw/Hearts Spades Diamonds Clubs/;
my @rank = qw/Ace 2 3 4 5 6 7 8 9 10 Jack Queen King/;
my %suit; $suit{lc $_} = $_ for @suit;
my %rank; $rank{lc $_} = $_ for @rank;
 
my %predict;

my %ignore =(
	"Mesril"	=> 1,
	"Eldora"	=> 1,
	"sugarass"	=> 1,
	"Droplet"	=> 1,
	"Camazotz"	=> 1,
);
 
signal_add('message public', sub {
    	my ($server, $message, $nick, $address, $target) = @_;
	{ no warnings 'uninitialized'; return if ($ignore{$nick} == 1); }

	if($nick =~ /amiigo\|\d+/i){ return; }

	my $me = $server->{nick};
		if ($message =~ /^$me[:,] i predict (?:the )?(\w+) of (\w+)/i) {
        	my ($rank, $suit) = (lc $1, lc $2);
        	my $proper_rank = $rank{$rank};
        	my $proper_suit = $suit{$suit};
        	if (defined $proper_rank && defined $proper_suit) {
            		$predict{$nick} = [ $proper_rank, $proper_suit ];
        	} else {
            		$server->command("MSG $target You predict the " . ($proper_rank // 'what') . " of " . ($proper_suit // 'what') . " now?");
        	}
    	}
});
 
sub card {
    	my ($server, $message, $nick, $address, $target) = @_;
	{ no warnings 'uninitialized'; return if ($ignore{$nick} == 1); }
 
	if($nick =~ /amiigo\|\d+/i){ return; }

    	if($message =~ m/^!card$/i){
        	my ($rank, $suit);
        	my $predict = delete $predict{$nick};
        	if ($predict) {
        		($rank, $suit) = @$predict;
        	} else {
            		$rank = $rank[rand(@rank)];
            		$suit = $suit[rand(@suit)];
        	}
        	$server->command("MSG $target $nick, your card is the $rank of $suit");
    	}
}
 
Irssi::signal_add('message public', 'card');