'use strict'

var app = require('app');
var BrowserWindow = require('browser-window');
var Menu = require('menu');
var Tray = require('tray');
var request = require('request');
var async = require('async');
var path = require('path');
var exec = require('child_process').exec;

// Get a users list of followed
var followed = [];
var currStreamers = [];
var prevStreamers = [];

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the javascript object is GCed.
var mainWindow = null;
var appIcon = null;

var getFollowed = function(username, cb) {
  //curl -H 'Accept: application/vnd.twitchtv.v3+json' -X GET https://api.twitch.tv/kraken/users/test_user1/follows/channels
  followed = [];
  request('https://api.twitch.tv/kraken/users/' + username + '/follows/channels', function(error, response, body) {
    if (!error) {
      var data = JSON.parse(body);
      for (var i = 0; i < data.follows.length; i++) {
        var streamer = data.follows[i];
        followed.push({streamName:streamer.channel.name, displayName:streamer.channel.display_name});
      }
      cb();
    }
  });
}

var getChannelStatus = function(channelName, callback) {
// curl -H 'Accept: application/vnd.twitchtv.v3+json' -X GET https://api.twitch.tv/kraken/streams/test_channel
  request('https://api.twitch.tv/kraken/streams/' + channelName.streamName, function(error, response, body) {
    if (!error) {
      console.log('body unparsed:',body);
      console.log('body:',JSON.parse(body));
      if( JSON.parse(body).stream != null ) {
        currStreamers.push(channelName);
      }
      callback();
    }
    else {
      console.log('error:',error);
    }
  });
}

var contextMenu = {} // We don't want a new menu every time

var minutes = .5, the_interval = minutes * 60 * 1000;
setInterval(function() {
 tick();
}, the_interval);

var tick = function() {
  getFollowed('the_mother_confessor', function() {
    prevStreamers = [];
    for( var streamer in currStreamers ){
      prevStreamers.push(currStreamers[streamer].streamName);
    }
    currStreamers = [];
    async.each(followed, getChannelStatus, function(err) {
      if(!err) {

        var selectedStreamer = null;
        var labels = [];
        for (var i = 0; i < currStreamers.length; i++) {
          labels.push({ label: currStreamers[i].displayName, type: 'normal', click: function(streamerName) { openStream(streamerName.label)}.bind(currStreamers[i]) });
        }

        appIcon.setToolTip('Online streamers.');

        if (currStreamers.length === 0) {
          appIcon.setImage(path.join(__dirname, 'img/dota2_gray.jpg'));
          labels.push({label: 'No live streams', type: 'normal'});
        }
        else {
          appIcon.setImage(path.join(__dirname, 'img/dota2.png'));
        }
        labels.push({ label: 'Commands', type: 'separator' });
        labels.push({ label: 'Quit', type: 'normal', click: close });
        contextMenu = Menu.buildFromTemplate(labels);
        appIcon.setContextMenu(contextMenu);

        for(var j = 0; j < currStreamers.length; j++) {
          if (prevStreamers.indexOf(currStreamers[j].streamName) == -1) {
            notifyNewStreamer(currStreamers[j]);
          }
        }

      }
      else {
        console.log('err:',err);
      }
    });
  });
}

var streamWindow = {};

var openStream = function(streamerName) {
  console.log("open stream", streamerName);
  exec('/usr/local/bin/livestreamer twitch.tv/' + streamerName + ' best', function(error, stdout, stderr) {
    if (error) {
      console.log('exec error: ' + error);
    }
  });

}

app.on('ready', function() {
  appIcon = new Tray(path.join(__dirname, 'img/dota2_gray.jpg')); // Only need one Tray icon
  tick();
});

var notifier = require('node-notifier');

var notifyNewStreamer = function(streamer) {
  notifier.notify({
    'title': 'Now Online',
    'message': streamer.displayName,
    'icon': path.join(__dirname, 'img/dota2.png')
  });
}

var close = function() {
  streamWindow = null;
  appIcon.destroy();
  process.exit(0);
}
