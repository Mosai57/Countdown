use strict;
use Irssi qw/signal_add/;
use Irssi::Irc;
use warnings;
use 5.014;

use vars qw($VERSION %IRSSI);

$VERSION = "1";
%IRSSI = (
	authors		=> '...',
	contact 		=> '...',
	name		=> '...',
	description 	=> '...',
	changed 		=> 'yyyy-mm-dd hh:mm (UTC-8:00)',
);

use constant URL_REGEX  => '(?:https?://)(?:\S+(?::\S*)?@)?(?:(?!10(?:\.\d{1,3}){3})(?!127(?:\.\d{1,3}){3})(?!169\.254(?:\.\d{1,3}){2})(?!192\.168(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\x{00a1}-\x{ffff}0-9]+-?)*[a-z\x{00a1}-\x{ffff}0-9]+)(?:\.(?:[a-z\x{00a1}-\x{ffff}0-9]+-?)*[a-z\x{00a1}-\x{ffff}0-9]+)*(?:\.(?:[a-z\x{00a1}-\x{ffff}]{2,})))(?::\d{2,5})?(?:/[^\s]*)?';

my @comp_strings = (
	"DateTime",
	"ExifImageLength",
	"ExifImageWidth",
	"Make",
	"Model",
	"Software"
);

Irssi::signal_add('message public', sub{
	my ($server, $message, $nick, $address, $target) = @_;
	
	{ no warnings 'uninitialized'; }

	if($message =~ /^!exif\s/i){
		if($message =~ m~${\(URL_REGEX)}~i){
			my @mess = split(' ', $message);
			shift @mess;
			
			foreach(@mess){
				if($_ =~ m~${\(URL_REGEX)}~i){
					my @exif_info = `identify -format '%[EXIF:*]' $_`;
					
					s/^exif://g for @exif_info;

					my @str;
					foreach(@exif_info){
						my @hold = split('=', $_);
						if($hold[0] ~~ @comp_strings){
							push(@str, $hold[1]);
						}
					}
	
					if($str[0] eq ""){
						$server->command("MSG $target ! No EXIF data found for that image.");
					} else{
						$server->command("MSG $target ! EXIF data: Size: $str[2] x $str[1], Taken: $str[0], Make: $str[3], Model: $str[4], Software: $str[5]");
					}
				}
			}
		} else { return; }
	}
});
