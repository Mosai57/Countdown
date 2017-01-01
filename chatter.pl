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
	description 		=> 'IRC Quote script. Returns a random line from a provided log file.',
	changed 		=> 'yyyy-mm-dd hh:mm (UTC-8:00)',
);

#Prevents lines from/containing whatever the script user wishes to omit
constant BLACKLIST_REGEX => 'REGEX_GOES_HERE';

my @log_files = (
	#log files go here
);

my $tweet_flag = 0;
my $line;

sub chatter{
	my ($server, $message, $nick, $address, $target) = @_;
	my $flag = 0;
	
	{ no warnings 'uninitialized'; return if ($ignore{$nick} == 1); }

	if($message =~ /^!chatter$/i){
		my $chatnet = $server->{chatnet};
		
		$line = random_quote_line($target, $chatnet);

		do{
			if($line =~ m~${\(BLACKLIST_REGEX)}~i){	
				$line = random_quote_line($target, $chatnet);
			} else{
				$flag = 1;
			}
		}while($flag == 0);

		$flag = 0;

		$line =~ s/^\d{2}:\d{2} <[^>]+> //;	
		$server->command("MSG $target $line") if $line;
	}
}

sub ramble{
	my($server, $message, $nick, $address, $target) = @_;
	no warnings 'uninitialized';
	{ no warnings 'uninitialized'; return if ($ignore{$nick} == 1); }
	
	if($message =~ /^!ramble$/i){
		## SET UP BLOCK ##

			my $chatnet = $server->{chatnet};
			my $limit = 8 + int(rand(3));
			my $time_limit = time + 10;

			my @target_logfiles = grep { /$target/i } @log_files;
			my $log_to_open = $target_logfiles[rand @target_logfiles];
			
			my @string_to_make;	

		## SET UP BLOCK END##

		open(my $f, '<', "/home/pi/.irssi/logs/$chatnet/".$log_to_open) or return ("Error: still nope $!");

		while(scalar(@string_to_make) < $limit || (scalar(@string_to_make) > 3 && int(rand(2)) == 0)){
			my @lines;
			for (1..10) {
    				# choose NUM_LINES random lines
    				my $idx = 0;
    				while(<$f>) {
        				$idx++;

        				if (@lines < $limit) {
         					push @lines, $_;
           					next;
        				}
        				if (rand($idx / $limit) < 1) {
            					$lines[rand @lines] = $_;
					}
    				}
			}

			
			#Formatting	
			$line =~ s/^\d{2}:\d{2} <[^>]+> //ig for @lines;

			for(my $idx = 0; $idx < $limit; $idx++){
				my @exploded_line = split(' ', $lines[$idx]);
				my $word = $exploded_line[int(rand(scalar(@exploded_line)))];
				my $count = 0;
				while($word =~ m~${\(BLACKLIST_REGEX)}~i && $count < 10){
					my $word = $exploded_line[int(rand(scalar(@exploded_line)))];
					$count++;
				}
				if($word =~ m~${\(BLACKLIST_REGEX)}~i){
					undef $word;
					next;
				} else{
					push(@string_to_make, $word);
				}
			}
			if($time_limit < time){
				$server->command("Took too long to make a sentence :(");
				return;
			}
		}
		my $output = join(' ', @string_to_make);
			
		$output =~ s/\s+$//;

		$server->command("MSG $target $output");
		close($f);		
	}
}


sub random_quote_line {
	my ($target, $chatnet) = @_;
	my $count_limit = 0;	

	my $log_to_open = $log_files[int(rand(scalar(@log_files)))];

	while($log_to_open !~ /$target/i){
		$log_to_open = $log_files[int(rand(scalar(@log_files)))];
		$count_limit++;
		if($count_limit == 25){
			return "Error: No available log files for this channel $!";
		}
	}

        open(my $f, '<', "/path/to/dir/".$log_to_open) or return ("Error: cannot open log file $!");

	my $line;
        my $count = 0;
        while (<$f>) {
		chomp;
		++$count;
		$line = $_ if 0 == int rand($count);
        }
	return $line;
}   

signal_add('message public', \&chatter);
signal_add('message public', \&ramble);
