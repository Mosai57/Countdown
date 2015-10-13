# Countdown
Irssi script to add and manage countdowns to events.

SHC => Short Hand Command.  A one word phrase to add a date to the database under.  
Used to call the countdown function for that entry in the database.

Each event entry has three pieces to it, the SHC, the date timestamp, and the name of 
the user that registered the event.

The script is built to curate its on database. If the current date is beyond what the date registered to an event is, the script will remove that database entry and free up the SHC for that event.

To add an event to the database, the command is:
  
	!addcdn (shc) (date in mm/dd/yyyy format)

Once an event is in the database it can be accessed until it expires using the command:
 
	!cdn (shc)

To check what date a particular event occurs on, use the following command:

	!datefor (shc)

To modify an event that you have entered, use the following command:
	
	!moddate (shc) (new date in mm/dd/yyyy format)

To delete an event that you have entered, use the following command:

	!deldate (shc)

A demonstration bot is set up on mibbit. Connection instructions are below

	Server:	  irc.mibbit.net
	Channel:  #ircdemon
	
Web Link: [#ircdemon on irc.mibbit.net](https://kiwiirc.com/client/irc.mibbit.net/?nick=&theme=basic#ircdemon)
