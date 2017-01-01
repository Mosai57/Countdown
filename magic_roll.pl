use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;
use vars qw($VERSION %IRSSI);
 
$VERSION = "1";
%IRSSI = (
        authors         	=> 'Jaykob Ross',
        contact             	=> 'mosai57@gmail.com',
        name            	=> 'magic_roll',
        description     	=> 'returns a line from a file.',
);

sub main{
	my($server, $message, $nick, $address, $target) = @_;

	if($nick =~ /amiigo\|\d+/i){ return; }

	if($message =~ /^!spell\s?/i){
		my @args = split(' ', $message);

		my $channel = $server->channel_find($target);
		my @users = @{[$channel->nicks]};
		my $line = get_line("s");

		if($channel && defined $args[1] && $channel->nick_find($args[1])){
			$args[1] = $channel->nick_find($args[1]);
			s/\b(the )?Target\b/$args[1]->{nick}/i for $line;
		} else{
			s/\b(the )?Target\b/$users[int(rand(scalar(@users)))]->{nick}/i for $line;
		}
		s/^\d+\s// for $line;
		s/(the )?Caster/$nick/i for $line;

		if($line =~ /\d+d\d+/i){
			$line = process_line($line);
			if(int(rand(10)) != 7){				
				$server->command("MSG $target $line.");
			} else{
				my $removal = get_line("r");
				s/^\d+\s// for $removal;
				$removal = process_line($removal);
				$server->command("MSG $target $line. Wont remove until \l$removal.");
			}
		} else{
			if(int(rand(10)) != 7){
				$server->command("MSG $target $line.");
			} else{
				my $removal = get_line("r");
				s/^\d+\s// for $removal;
				$removal = process_line($removal);
				$server->command("MSG $target $line. Wont remove until \l$removal.");
			}
		}
	}
}

sub get_line{
	my $file;
	if($_[0] eq "s"){
		$file = "spells.txt";
	} elsif($_[0] eq "r"){
		$file = "requirements.txt";
	}

	open (my $f, '<', "/home/moberry/magic/$file") or return ("Error: Cannot find file $file $!");

	my $line;
	my $count = 0;

	while(<$f>){
		chomp;
		++$count;
		$line = $_ if 0 == int rand($count);
	}

	s/\bhe\b/they/gi for $line;
	s/\bhis\b/their/gi for $line;
	s/\bhim\b/them/gi for $line;
	s/\bthey thinks\b/they think/gi for $line;
	s/\bthey is\b/they are/gi for $line;
	s/\basks\b/ask/gi for $line;
	s/\bthey\'s\b/they\'re/gi for $line;
	s/\bthey knows\b/they know/ for $line;
	s/\bthey has\b/they have/ for $line;

	close $f;
	return $line;
}

sub process_line {
	my $line = $_[0];
	my $prev = 0;

	my $x = sub { 
		if (defined($1)) {
			return $prev = d($1, $2);
		} elsif (defined($3)) {
			return ($prev == 1 ? $3 : $4);
		}
		return '';
	};

	$line =~ s#\b(\d*)d(\d+)|\(([^/]+)/([^)]+)\)#$x->()#ge;
	return $line;
}

sub d {
        my ($n, $s) = @_;
        $n ||= 1; # so that 'd6' is treated as '1d6'
        # <n>d<s> returns a random number between <n> and <n*s>
        # HOWEVER this is not an even distribution; numbers near the middle are more likely than extremely high or extremely low numbers
        my $total = 0;
        for (1..$n) {
		my $roll = 1 + int rand $s;
            	$total += $roll;
        }
        return $total;
}

signal_add('message public', \&main);
