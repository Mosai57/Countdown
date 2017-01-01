use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;
use Switch;
use vars qw($VERSION %IRSSI);
 
$VERSION = "1";
%IRSSI = (
        authors         		=> 'Jaykob Ross',
        contact             	=> 'mosai57@gmail.com',
        name            		=> 'Moberry',
        description     		=> 'Sends a random phrase to an irc channel when triggered.',
        changed               	=> '2014-1-1 19:28 (UTC-8:00)',
);

my @responses = (
	"Yes.",
	"No.",
	"That's a terrible idea.",
	"What? Sorry, I fell asleep while reading that.",
	"*snrk*",
	"Uhhhhhh... No comment.",
);

my @emotes = ( "D:", ":|", ":D", );

sub format_uptime{
	# Initialize variables
	my $string = "";
	my $uptime = `uptime`;
	my $emote = "";

	# Match the capture groups
	$uptime =~ m/(\d+ days,)/;
	my $days = $1;
	$uptime =~ m/(\d+:\d+,)/;
	my $time = $1;

	# Formatting
	$uptime =~ s/up \d days,//;
	$uptime =~ s/\d+:\d+,//;
	$uptime =~ s/\s+/ /g;
	$days =~ s/ days,//;
	$time =~ s/,//;

	# Determine emote
	if(!($days) || $days < 3){
		$emote = $emotes[0];
	} elsif($days >= 3 && $days < 7){
		$emote = $emotes[1];
	} elsif($days >= 7){
		$emote = $emotes[2];
	}

	$string = "It has been ";
	if($days){ $string .= "$days days, "; }
	$string .= "$time since the last system crash $emote (Uptime: $uptime)";

	return $string; 
}


#### FRONTEND COMMANDS ####

sub info{
  	my($server, $message, $nick, $address, $target) = @_;
	my $me = $server->{nick};

	if($nick =~ /amiigo\|\d+/i){ return; }

   	if($message =~ /^$me[:,]\s/i){
		my(undef, $command) = split ' ', $message;
			if($command =~ /uptime$/i){ 
				my $output = format_uptime();
				$server->command("MSG $target $output");
			}
			elsif($command =~ /lscpu$/i){ 
				my @lscpu = `lscpu`;
				chomp @lscpu;
				s/:\s+/: / for @lscpu;
				my $response = join(', ', @lscpu);
				$server->command("MSG $target $response"); 
			}
			else{ return; }	
	}  
}

sub respond{
	my($server, $message, $nick, $address, $target) = @_;
	
	if($nick =~ /amiigo\|\d+/i){ return; }

	my $me = $server->{nick};
	if($message =~ /right,? $me\?/i){
		$server->command("MSG $target " . $responses[int(rand(scalar(@responses)))]);
	}
	if($message =~ /fuck you(\s\w+)? $me/i){
		$server->command("MSG $target t(*-*t)");
	}
}


signal_add('message public', \&info);
signal_add('message public', \&respond);
