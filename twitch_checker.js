'use strict'

var request = require('request');

// Get a users list of followed
var followed = [];

var getFollowed = function(username, cb) {
  //curl -H 'Accept: application/vnd.twitchtv.v3+json' \
// -X GET https://api.twitch.tv/kraken/users/test_user1/follows/channels

  request('https://api.twitch.tv/kraken/users/' + username + '/follows/channels', function(error, response, body) {
    if (!error) {
      var data = JSON.parse(body);
      for (var i = 0; i < data.follows.length; i++) {
        var streamer = data.follows[i];
        followed.push(streamer.channel.display_name);
      }
      cb();
    }
  });
}

var getChannelStatus = function(channelName) {
// curl -H 'Accept: application/vnd.twitchtv.v3+json' \
// -X GET https://api.twitch.tv/kraken/streams/test_channel

  request('https://api.twitch.tv/kraken/streams/' + channelName, function(error, response, body) {
    if (!error) {
      if( JSON.parse(body).stream != null ) {
        console.log('%s is online', channelName);
      }
    }
  });
}

if (process.argv.length < 3) {
  console.log('usage: node twitch_checker.js [twitch_username]')
  process.exit(1);
}

var args = process.argv.slice(2);

getFollowed(args[0], function() {
  console.log('========= Channels Online =========');
  for (var i = 0; i < followed.length; i++) {
    getChannelStatus(followed[i]);
  }
});
