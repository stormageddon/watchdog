'use strict'

var app = require('app');
var BrowserWindow = require('browser-window');
var Menu = require('menu');
var Tray = require('tray');
var request = require('request');
var async = require('async');

// Get a users list of followed
var followed = [];
var currStreamers = [];

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the javascript object is GCed.
var mainWindow = null;
var appIcon = null;

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

var getChannelStatus = function(channelName, callback) {
// curl -H 'Accept: application/vnd.twitchtv.v3+json' \
// -X GET https://api.twitch.tv/kraken/streams/test_channel
  console.log('channelname:',channelName,callback);
  request('https://api.twitch.tv/kraken/streams/' + channelName, function(error, response, body) {
    if (!error) {
      if( JSON.parse(body).stream != null ) {
        console.log('%s is online', channelName);
        currStreamers.push(channelName);
      }
      console.log('what?');
      callback();
    }
    else {
      console.log('error:',error);
    }
  });
}

if (process.argv.length < 3) {
  console.log('usage: node twitch_checker.js [twitch_username]')
  process.exit(1);
}

var args = process.argv.slice(2);


var dockMenu = Menu.buildFromTemplate([
  { label: 'New Window', click: function() { console.log('New Window'); } },
  { label: 'New Window with Settings', submenu: [
    { label: 'Basic' },
    { label: 'Pro'},
  ]},
  { label: 'New Command...'},
]);

app.dock.setMenu(dockMenu);

getFollowed(args[0], function() {
  console.log('========= Channels Online =========');

  async.each(followed, getChannelStatus, function(err) {
    if(!err) {
      appIcon = new Tray('/Users/Mike/Downloads/dota2.jpg');
      var labels = [];
      for (var i = 0; i < currStreamers.length; i++) {
        labels.push({ label: currStreamers[i], type: 'radio' });
      }
      var contextMenu = Menu.buildFromTemplate(labels);
      appIcon.setToolTip('Online streamers.');
      appIcon.setContextMenu(contextMenu);
    }
    else {
      console.log('err:',err);
    }
  });
});

app.on('ready', function() {
/*  mainWindow = new BrowserWindow({width: 800, height: 600});
  mainWindow.loadUrl('http://google.com');
  mainWindow.on('closed', function() {
    mainWindow = null;
  });*/


});
