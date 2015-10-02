# Countdown
Irssi script to add and manage countdowns to events.

SHC => Short Hand Command.  A one word phrase to add a date to the database under.  
Used to call the countdown function for that entry in the database.

To add an event to the database, the command is:
  
	!addcdn (shc) (date in mm/dd/yyyy format)

Once an event is in the database it can be accessed until it expires using the command:
 
	!cdn (shc)

A demonstration bot is set up on mibbit. Connection instructions are below

	Server:	 irc.mibbit.net
	Channel: #ircdemon
