use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;
use DBM::Deep;

use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (
	authors		=> 'Jaykob Ross',
	contact 	=> 'Mosai@mosai57.com',
	name		=> 'Quotes',
	description 	=> 'Adds and returns quotes to and from a .dp file to irc channels.',
	created		=> '2015-08-03',
	changed 	=> '2015-08-03',
);

########## DATABASE FUNCTIONS ##########

sub open_db {
    my $db_path = Irssi::get_irssi_dir . '/db/';
    -e $db_path or mkdir $db_path;
    my $db_file = $db_path . 'quotes.db';
    my $db = new DBM::Deep(file => $db_file);      
    return $db;
}

sub add_quote {
    my ($nick, $chan, $time, $text) = @_;
    my $db = open_db();
    my $a = ( $db->{all} ||= [] );
    my $c = ( $db->{lc $chan} ||= [] );
   
    my $id = ++ $db->{nextid};
    
    my $quote = [ $id, $nick, $chan, $time, $text ];
    push @$a, $quote;
    push @$c, $quote;
    return $quote;
}

########## RETRIEVAL FUNCTIONS ##########

sub get_any{
	my $channel = $_[0];
	my $quote_db = open_db();
	my $c = $quote_db->{lc $channel};

	return format_quote($c->[int(rand(scalar(@$c)))]);
}

sub get_by_word{
	my ($channel, $word) = @_;
	my $quote_db = open_db();
	my $c = $quote_db->{lc $channel};
	my @matches;
	
	my $iterator = array_iterator($c);
	while($iterator->()){
		if($_->[4] =~ /\b\Q$word\E\b/i){
			push(@matches, $_);
		}
	}
	
	if(@matches){
		return format_quote($matches[int(rand(scalar(@matches)))]);
	} else{
		return "Could not find any quotes matching $word.";
	}
}

########## TOOLS ##########

sub format_quote{
	my ($id, $nick, $chan, $time, $text) = @{ $_[0] };
	return "Quote $id by $nick at " . scalar(localtime $time) . ": $text";
}

sub array_iterator {
	my $array = shift;
	my $i = 0;
	return sub {
		if($i >= @$array) {
			return $_ = undef;
		}
		return $_ = $array->[$i++];
	};
}

########## IRSSI SIGNALS ##########

sub add_quote_frontend{
	my ($server, $message, $nick, $address, $target) = @_;
	
	if($message =~ /^!addquote (\W*|\w*|\d*|\D*)/){
		s/^!addquote\s// for $message;
		add_quote($nick, $target, time(), $message);
	}
}

sub get_quote_frontend{
	my ($server, $message, $nick, $address, $target) = @_;
	
	if($message =~ /^!quote( (\W*|\w*|\D*|\d*))?/){
		s/^!quote\s*// for $message;
		if(!$message){
			$server->command("MSG $target " . get_any($target));
		} elsif($message =~ /(\W*|\w*|\D*|\d*)/){
			$server->command("MSG $target " . get_by_word($target, $message));
		}
	}
}

signal_add('message public', \&add_quote_frontend);
signal_add('message public', \&get_quote_frontend);