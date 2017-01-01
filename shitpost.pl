use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;
use Games::Dissociate;
use File::Slurp;

use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (
	authors		=> '...',
	contact 		=> '...',
	name		=> '...',
	description 	=> '...',
	changed 		=> 'yyyy-mm-dd hh:mm (UTC-8:00)',
);

my $group_size = 4;

sub shitpost{
	my ($server, $message, $nick, $address, $channel) = @_;
	
	my $chatnet = $server->{chatnet};

	if($message =~ /^!shitpost\s*$/i) {
		my $file = read_file("/home/histy/.irssi/logs/$chatnet/$channel" . ".log");
		$file =~ s/^\d{2}:\d{2} -!-.*//ig;
		$file =~ s/^---.*//ig;
		$file =~ s/^\d{2}:\d{2} //ig;
		$server->command("MSG $channel " . 
			dissociate(	
				$file, 				# The file to work with			
				$group_size - int(rand(3)),	# The Group size (can be either 4, 3, or 2)
				int(rand(33))+16  		# Max size (16 to 48 characters long)
			)
		);
	}
}

signal_add("message public", \&shitpost);
