use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;

use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (
	authors			=> 'Jaykob Ross',
	contact 		=> 'mosai57@gmail.com',
	name			=> 'Rock Paper Scissors',
	description 		=> 'Plays rock paper scissors via irc',
);
  
my @options_rps = ( "rock", "paper", "scissors" );
my @options_rpsls = ( "rock", "paper", "scissors", "lizard", "spock" );

my %final_hash = (
	'rock'     => { 
		'rock'	   => 'We tied', 
		'paper'    => 'You lose', 
		'scissors' => 'You win',
		'lizard'   => 'You win',
		'spock'    => 'You lose'
	},
 	'paper'	   => { 
		'rock'     => 'You win',
		'paper'	   => 'We tied', 
		'scissors' => 'You lose', 
		'lizard'   => 'You lose',
		'spock'    => 'You win'
	},
	'scissors' => { 
		'rock'     => 'You lose',
		'paper'    => 'You win',
		'scissors' => 'We tied', 
		'lizard'   => 'You win',
		'spock'    => 'You lose'
	},
	'lizard'   => {
		'rock'	   => 'You lose',
		'paper'	   => 'You win',
		'scissors' => 'You lose',
		'lizard'   => 'We tied',
		'spock'    => 'You win'
	},
	'spock'	   => {
		'rock'     => 'You win',
		'paper'    => 'You lose',
		'scissors' => 'You win',
		'lizard'   => 'You lose',
		'spock'    => 'We tied'
	}
);

sub rps{
  	my ($server, $message, $nick, $address, $target) = @_;
  	my @arguments = split(' ', $message);
  
  	my $selection = $options_rps[int(rand(scalar(@options_rps)))];
  	my $final = "I choose $selection... ";
  	my $input = $arguments[1];
  
  	if($message =~ /^!rps\s/i){
    		if($input =~ /^((rock)|(paper)|(scissors))$/i){
	  		$final .= $final_hash{$input}{$selection};
	  		$server->command("MSG $target " . $final);
		} else{
	  		$server->command("DESCRIBE $target gives $nick a funny look");
		}
  	}
	undef $selection;
  	undef @arguments;
}

sub rpsls{
  	my ($server, $message, $nick, $address, $target) = @_;
  	my @arguments = split(' ', $message);
  
  	my $selection = $options_rpsls[int(rand(scalar(@options_rpsls)))];
  	my $final = "I choose $selection... ";
  	my $input = $arguments[1];
  
  	if($message =~ /^!rpsls\s/i){
    		if($input =~ /^((rock)|(paper)|(scissors)|(lizard)|(spock))$/i){
	  		$final .= $final_hash{$input}{$selection};
	  		$server->command("MSG $target " . $final);
		} else{
	  		$server->command("DESCRIBE $target gives $nick a funny look");
		}
  	}
  	undef $selection;
  	undef @arguments;
}

Irssi::signal_add('message public', 'rps');
Irssi::signal_add('message public', 'rpsls');
