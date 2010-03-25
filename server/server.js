/*
 DuelParty: server.js
 Purpose: Handles game connections on the site.
 Notes: Loosely adapted from Ryan Dahl's node.js chat example at http://github.com/ry/node_chat/blob/master/server.js
 */


HOST = null;	// Host on localhost
PORT = 8001;

var fu = require("./fu");
var sys = require("sys");
var utils = require("./utils");

var MESSAGE_BACKLOG = 200;
var SESSION_TIMEOUT = 60 * 1000;
var CALLBACK_TIMEOUT = 30 * 1000;

/*	
 Class: Message
 Purpose: Holds data for a single chat message.
 */
function Message(fromUser, type, text) {
	/* Public variable declarations */
	this.fromUser = fromUser;
	this.type = type;
	this.text = text;
	this.timestamp = new Date();
}

/*	
 Class: Channel
 Purpose: Holds data for a certain chat channel.
 Notes: Since there are many channel objects, we don't want to duplicate complex methods.
 Most channel manipulation methods are in channel manager, of which there is only one.
 */
function Channel(channelID) {
	/* Public variable declarations */
	this.id = channelID;						// The unique channel id
	this.messages = [];							// An array of all messages sent in the channel
	this.timestamp = (new Date()).getTime();	// The last date on which the channel was updated
	this.callbacks = [];						// Long poll callbacks to 'push' new messages to the users
	this.numUsers = 0;							// The number of users currently in this channel
}

/*	
 Singleton Class: ChannelManager
 Purpose: Operates on channel data objects to update and maintain them.
 */
var channelManager = new function() {
	
	/* Private variable declarations */
	var channels = new utils.Hash();			// Stores channel data objects
	
	/*	
	 Method: queryChannel
	 Purpose: Returns new messages in the given session data object for the given user.
	 */
	this.queryChannel = function(channelID, userID, since, callback) {
		var channel = channels.getItem(channelID);
		
		// Get all messages since the given time
		var matching = [];
		var messages = channel.messages;
		for (var i = 0; i < messages.length; i++) {
			var message = messages[i];
			if (message.timestamp.getTime() > since) {
				matching.push(message)
			}
		}
		
		if (matching.length != 0) {
			callback(matching);
		} else {
			channel.callbacks.push({ timestamp: new Date(), callback: callback });
		}
	}

	/*	
	 Method: messageChannel
	 Purpose: Adds new messages to the channel and manage callbacks
	 */
	this.messageChannel = function(channelID, fromUser, type, text) {
		var channel = channels.getItem(channelID);
		var message = new Message(fromUser, type, text);
		channel.messages.push(message);
		
		// Notify waiting polls of the new message
		while (channel.callbacks.length > 0) {
			channel.callbacks.shift().callback([message]);
		}
		
		// Start shifting if there are too many messages in this channel
		while (channel.messages.length > MESSAGE_BACKLOG) {
			channel.messages.shift();
		}
		
		// Print new message to terminal
		sys.puts("New message from user id {{" + fromUser + "}}: " + text);	
	}

	/*	
	 Method: createChannel
	 Purpose: Creates a new channel for the supplied users.
	 Returns: The id of the new channel
	 */
	this.createChannel (users) {
		// Create a new channel for the users
		var channelID = channels.length;
		var channel = new Channel(channelID);
		channel.numUsers = users.length;
		
		// Associate the channel with all users
		for (var i = 0; i < users.length; i++) {
			var userID = users[i];
			sessionManager.addChannelToSession(userID, channelID);
		}
		
		return channelID;
	}
	
	/*	
	 Method: removeUserFromChannel
	 Purpose: Removes a user from the given channel.
	 */
	this.removeUserFromChannel = function(userID, channelID) {
		var channel = channels.getItem(channelID);
		channel.numUsers--;		
		this.messageChannel(channelID, userID, "sys", "Conversation participant {{" + userID + "}} has disconnected.");
		
		// Delete the channel if there are no more users left
		if (channel.numUsers == 0) {
			channels.removeItem(channelID);
			delete channel;
		}
	}

	/*	
	 Private Method: clearOldChannelCallbacks
	 Purpose: Loops through all channels and clears old callbacks, ensuring closure of dead requests.
	 */
	function clearOldChannelCallbacks() {
		var now = new Date();
		for (var id in channels.items) {
			var channel = channels.items[id];
			while (channel.callbacks.length > 0 && now - channel.callbacks[0].timestamp > CALLBACK_LIFETIME) {
				channel.callbacks.shift().callback([]);
			}
		}
	}
	setInterval(clearOldChannelCallbacks, 5000);
}

/*	
 Class: Session
 Purpose: Holds data for a single user session.
 Notes: A user maintains only one session while connected to Anchat, but can be part of multiple 
 channels during this session.
 */
function Session(userID) {
	/* Public variable declarations */
	this.userID = userID;
	this.timestamp = new Date();
	this.channels = [];
}

/*	
 Singleton Class: SessionManager
 Purpose: Operates on session data objects to update and maintain them.
 */
var sessionManager = new function() {
	var sessions = new utils.Hash();		// Stores arrays to associate users with sessions
	var userMatchPool = new Array();		// An array of all users waiting to be matched
	
	/*	
	 Method: isUserPartOfChannel
	 Purpose: Returns true if the user is part of the given channel.
	 */
	this.isUserPartOfChannel = function(userID, channelID) {
		var session = sessions.getItem(userID);
		if (session != null && session.channels.contains(channelID)) {
			return true;
		}
		return false;
	}
	
	/*	
	 Method: addChannelToSession
	 Purpose: Adds a record of the new channel to the user's session.
	 */
	this.addChannelToSession = function(userID, channelID) {
		var session = sessions.getItem(userID);
		session.push(channelID);
	}
	
	/*	
	 Method: createSessionForUser
	 Purpose: Opens a session object for the given user
	 */
	this.createSessionForUser = function(userID) {
		sessions.addItem(new Session(userID));
	}
	
	/*	
	 Method: anonymousMatch
	 Purpose: Match the given user with a single random partner and open a new session
	 */
	this.anonymousMatch = function(userID, callback) {
		// If this user doesn't already have a session, make one
		if (!sessions.hasItem(userID)) {
			this.createSessionForUser(userID);
		}
		
		// If there is nobody in the user match pool, add self and wait
		if (userMatchPool.length == 0) {
			userMatchPool.push({userID:userID, callback:callback});
			return;
		}
		
		// Randomly select from the pool of users
		// TODO: Change the selection method to ANCHAT STYLE
		var matchIndex = userMatchPool.length * Math.random();
		var partnerMatch = userMatchPool[matchIndex];
		var channelID = channelManager.createChannel({userID, partnerMatch.userID});
		
		// Notify callbacks of both users
		callback(partnerMatch.userID, channelID);
		partnerMatch.callback(userID, channelID);
		
		// Remove partner from the pool of users
		userMatchPool.splice(matchIndex, 1);
	}
	
	/*	
	 Method: destroySession
	 Purpose: Destroys the session of the given user and disconnects him from all channels.
	 */
	this.destroySession = function(userID) {
		var session = sessions.getItem(userID);
		
		if (!session) return;
		
		//Disconnect this user from all his channels
		for (var i = 0; i < session.channels.length; i++) {
			var channelID = session.channels[i];
			channelManager.removeUserFromChannel(userID, channelID);
		}
		delete this;
	}
	
	/*	
	 Private Method: clearOldSessions
	 Purpose: Loops through all sessions and destroys the ones that have been disconnected.
	 */
	function clearOldSessions() {
		var now = new Date();
		for (var id in sessions.items) {
			var session = sessions.items[id];
			if (now - session.timestamp > SESSION_TIMEOUT) {
				// Destroy self
				this.destroySession(session.userID);
			}
		}
	}
	setInterval(clearOldSessions, 1000);
}

/* Server Setup */
fu.listen(PORT, HOST);

/* Route: Opening a new anonymous chat window. */
fu.get("/newChannel", function (req, res) {
	   var userID = parseInt(req.uri.params["userID"], 10);
	   
	   // Check for bad userID
	   if (userID == null || userID == 0) {
		   res.simpleJSON(400, {error: "Invalid user id."});
		   return;
	   }
	   
	   // Open up a new anonymous chat
	   function connectedCallback(partnerID, channelID) {
		   res.simpleJSON(200, {partnerID:partnerID, channelID:channelID});
	   }
	   sessionManager.anonymousMatch(userID, connectedCallback);
	   });

/* Route: Leaving a chat channel. */
fu.get("/closeChannel", function (req, res) {
	   var userID = parseInt(req.uri.params["userID"], 10);
	   var channelID = parseInt(req.uri.params["channelID"], 10);
	   
	   if (!sessionManager.isUserPartOfChannel(userID, channelID)) {
		   res.simpleJSON(400, { error: "This user is not in this channel!" });
	   }
	   
	   channelManager.removeUserFromChannel(userID, channelID);
	   
	   res.simpleJSON(200, { });
	   });

/* Route: Closing a session. */
fu.get("/closeSession", function (req, res) {
	   var userID = parseInt(req.uri.params["userID"], 10);
	   
	   if (!sessionManager.sessionExists(userID)) {
		   res.simpleJSON(400, { error: "This session does not exist!" });
	   }
	   
	   sessionManager.destroySession(userID);
	   res.simpleJSON(200, { });
	   });

/* Route: Long polling for requesting new messages from a certain channel. */
fu.get("/recieveChannel", function (req, res) {
	   if (!req.uri.params["since"]) {
		   res.simpleJSON(400, { error: "Must supply since parameter." });
		   return;
	   }
	   
	   var userID = parseInt(req.uri.params["userID"], 10);
	   var channelID = parseInt(req.uri.params["channelID"], 10);
	   var since = parseInt(req.uri.params["since"], 10);
	   
	   if (!sessionManager.isUserPartOfChannel(userID, channelID)) {
		   res.simpleJSON(400, { error: "This user is not in this channel!" });
	   }
	   
	   function queryCallback(messages) {
		   res.simpleJSON(200, { messages: messages });
	   }
	   channelManager.queryChannel(channelID, userID, since, queryCallback);
	   });

/* Route: Sending a message to a certain channel. */
fu.get("/sendChannel", function (req, res) {
	   var userID = parseInt(req.uri.params["userID"], 10);
	   var channelID = parseInt(req.uri.params["channelID"], 10);
	   var text = req.uri.params["text"];
	   
	   if (!sessionManager.isUserPartOfChannel(userID, channelID)) {
		   res.simpleJSON(400, { error: "This user is not in this channel!" });
	   }
	   
	   channelManager.messageChannel(channelID, userID, "msg", text);
	   res.simpleJSON(200, {});
	   });
