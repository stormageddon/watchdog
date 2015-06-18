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
var config = {};

var setupWindow = {};

var loadData = function(err, data) {
  if (!err) {
    config = JSON.parse(data);
    username = config.user;
    if (username) {
      tick();
      setInterval(function() {
	if(username != null) {
	  tick();
	}
      }, the_interval);
    }
    else { // First time launching
      var dialog = require('dialog');
      var options = {
        type: "info",
        title: "Watchdog",
        buttons: ["Ok"],
        message: "Welcome to Watchdog",
        detail: "Welcome to Watchdog! Before you can use it, you will need to set your username in the settings."
      };
      openSetup();
    }
  }
  else {
    console.log("Error reading configuration:",err);
  }
}



var getFollowed = function(user, cb) {
  console.log('Getting followed for',username);
  //curl -H 'Accept: application/vnd.twitchtv.v3+json' -X GET https://api.twitch.tv/kraken/users/test_user1/follows/channels
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
      var stream = {}
      try {
        stream = JSON.parse(body).stream
      } catch(err) {
        console.log("Error parsing json:", err)
        stream = null
      }

      if( stream ) {
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
  console.log('tick:',username);
  followed = [];
  prevStreamers = [];

  getFollowed(username, function() {
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
            labels.push({
	      label: currStreamer.displayName,
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
          console.log('checking if already online',currStreamers[j]);
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

var streamWindow = null;

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


var openSetup = function() {
  setupWindow = new BrowserWindow({ width: 800, height: 600, show: true });
  var setupUrl = "file:///" + __dirname + "/setup.html"
  setupWindow.loadUrl(setupUrl);

  ipc.on('saveSetup', function(event, arg) {
    console.log('data:',arg);
    if (arg) {
      username = arg;
      config.user = username;
      console.log('Writing to ' + path.join(__dirname, 'config.json'));
      fs.writeFile(path.join(__dirname,'/config.json'), JSON.stringify(config), function(err) {
        if (err) throw err;
        console.log('Wrote config to file');
      });
      if (setupWindow != null) {
	setupWindow.close();
      }
      setupWindow = null;
      tick();
      setInterval(function() {
	if(username != null) {
	  tick();
	}
      }, the_interval);

    }
  });
}

var openSettings = function() {
  if (streamWindow == null) {
    streamWindow = new BrowserWindow({ width: 800, height: 600, show: true });
  }
  var pageURL = "file:///" + __dirname + "/settings.html";
  console.log('stream window:',streamWindow);
  console.log('pageURL',pageURL);
  streamWindow.loadUrl(pageURL);
  streamWindow.webContents.on('did-finish-load', function() {
    streamWindow.webContents.send('username', username);
  });

  ipc.on('saveSettings', function(event, arg) {
    console.log('data:',arg);
    if (arg) {
      username = arg;
      config.user = username;
      console.log('Writing to ' + __dirname + '/config.json');
      fs.writeFile(path.join(__dirname,'config.json'), JSON.stringify(config), function(err) {
        if (err) throw err;
        console.log('Wrote config to file');
      });
      if( streamWindow != null ) {
	streamWindow.close();
	streamWindow = null;
      }
      tick();
    }
  });
}

app.on('ready', function() {
  fs.readFile(path.join(__dirname,'config.json'), loadData);
  appIcon = new Tray(path.join(__dirname, 'img/dota2_gray.jpg')); // Only need one Tray icon
});

var notifier = require('node-notifier');

var notifyNewStreamer = function(streamer) {
  console.log('notify: ', streamer.displayName);
  console.log('notifier:',notifier);
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
