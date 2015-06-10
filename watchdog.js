'use strict'

var app = require('app');
var BrowserWindow = require('browser-window');
var Menu = require('menu');
var Tray = require('tray');
var request = require('request');
var async = require('async');
var path = require('path');
var exec = require('child_process').exec;
var fs = require('fs');


// Get a users list of followed
var followed = [];
var currStreamers = [];
var prevStreamers = [];

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the javascript object is GCed.
var mainWindow = null;
var appIcon = null;
var username = null;

var minutes = .5, the_interval = minutes * 60 * 1000;

var loadData = function(err, data) {
  if (!err) {
    console.log("User is",JSON.parse(data).user);
    username = JSON.parse(data).user;
    if (username) {
      tick();
      setInterval(function() {
	if(username != null) {
	  tick();
	}
      }, the_interval);
    }
  }
  else {
    console.log("Error reading configuration:",err);
  }
}

fs.readFile(__dirname + '/config.json', loadData);

var getFollowed = function(user, cb) {
  //curl -H 'Accept: application/vnd.twitchtv.v3+json' -X GET https://api.twitch.tv/kraken/users/test_user1/follows/channels
  console.log('getting followed for',user);
  followed = [];
  request('https://api.twitch.tv/kraken/users/' + user + '/follows/channels', function(error, response, body) {
    if (!error) {
      var data = JSON.parse(body);
      if (data) {
	for (var i = 0; i < data.follows.length; i++) {
          var streamer = data.follows[i];
          followed.push({streamName:streamer.channel.name, displayName:streamer.channel.display_name});
	}
	cb();
      }
    }
  });
}

var getChannelStatus = function(channel, callback) {
// curl -H 'Accept: application/vnd.twitchtv.v3+json' -X GET https://api.twitch.tv/kraken/streams/test_channel
  request('https://api.twitch.tv/kraken/streams/' + channel.streamName, function(error, response, body) {
    if (!error) {
      console.log('body unparsed:',body);
      console.log('body:',JSON.parse(body));
      if( JSON.parse(body).stream != null ) {
        currStreamers.push(channel);
      }
      callback();
    }
    else {
      console.log('error:',error);
    }
  });
}

var contextMenu = {} // We don't want a new menu every time




var tick = function() {
  console.log('username:',username);
  getFollowed(username, function() {
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
          (function(currStreamer) {
//	    var currStreamer = currStreamers[i];
            labels.push({
	      label: currStreamer.displayName,//currStreamers[i].displayName,
	      type: 'normal',
	      click: function() { openStream(currStreamer); }
	    });
          })(currStreamers[i]);
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
	labels.push({ label: 'Settings', type: 'normal', click: openSettings });
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

var openStream = function(streamer) {
  console.log("open stream", streamer);
  exec('/usr/local/bin/livestreamer twitch.tv/' + streamer.streamName + ' best', function(error, stdout, stderr) {
    if (error) {
      console.log('exec error: ' + error);
    }
  });
}

var dialog = require('dialog');
var ipc = require('ipc');

var openSettings = function() {
//  var win = streamWindow;  // window in which to show the dialog
//  console.log(dialog.showMessageBox({ type: 'info', buttons: ['Save Settings'], title: 'Settings', message: 'Configure Watchdog here', detail: 'Detailed stuff here' }));
  streamWindow = new BrowserWindow({ width: 800, height: 600, show: true });
  streamWindow.loadUrl("file:///" + __dirname + "/settings.html");
  streamWindow.webContents.on('did-finish-load', function() {
    streamWindow.webContents.send('username', username);
  });

  ipc.on('saveSettings', function(event, arg) {
    console.log('data:',arg);
    if (arg) {
      username = arg
    }
  });
}

app.on('ready', function() {
  appIcon = new Tray(path.join(__dirname, 'img/dota2_gray.jpg')); // Only need one Tray icon
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
