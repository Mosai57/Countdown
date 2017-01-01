use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;
use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (author => 'Jaykob Ross', contact => 'mosai57@gmail.com', name => 'Basic.pl');

sub main_functions{
    my($server, $message, $nick, $address, $target) = @_;
    
    my $me = $server->{nick};

    if($message =~ /^$me[:, ]\s/i){
	my(undef, $command) = split ' ', $message;
	if($command =~ /uptime/i){
	  $server->command("MSG $target " . `uptime`);
	}elsif($command =~ /lscpu/i){
	  my @lscpu = `lscpu`;
	  chomp @lscpu;
	  s/:\s+/: / for @lscpu;
	  my $response = join(' ', @lscpu);
	  $server->command("MSG $target $response");
	}
    }
}

signal_add('message public', 'main_functions');	
