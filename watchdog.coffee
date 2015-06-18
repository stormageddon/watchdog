'use strict'

app = require('app')
BrowserWindow = require('browser-window')
Menu = require('menu')
Tray = require('tray')
request = require('request')
async = require('async')
path = require('path')
exec = require('child_process').exec
fs = require('fs')

# Get a list of followed
followed = []
currStreamers = []
prevStreamers = []

# Keep a global reference of the window object, if you don't, the window will
# be closed automatically when the javascript object is GCed
mainWindow = null
appIcon = null
username = null
minutes = .5
the_interval = minutes * 60 * 1000
config = {}
setupWindow = {}

loadData = (err, data)->
  if not err
    config = JSON.parse(data)
    username = config.user
    if username
      tick()
      setInterval( ->
        tick() if username
      , the_interval)
    else
      openSetup()
  else
    console.log 'Error reading configuration:',err

getFollowed = (user, cb)->
  followed = []
  request "https://api.twitch.tv/kraken/users/#{user}/follows/channels", (error, response, body)->
    if not error
      data = JSON.parse(body)
      if data
        followed = ({streamName:streamer.channel.name, displayName:streamer.channel.display_name} for streamer in data.follows)
        cb()

getChannelStatus = (channel, callback)->
  console.log 'get channel status',channel, callback
  request "https://api.twitch.tv/kraken/streams/#{channel.streamName}", (error, response, body)->
    if not error
      stream = {}
      try
        stream = JSON.parse(body).stream
      catch err
        console.log 'Error parsing json:', err
        stream = null
        callback(err)
      currStreamers.push(channel) if stream and currStreamers.indexOf(channel) == -1
      callback()
    else
      console.log 'error:',error
      callback(error)

contextMenu = {} # We don't want a new menu every time

tick = ->
  console.log 'tick:',username
  followed = []
  prevStreamers = []

  getFollowed username, ->
    prevStreamers = (streamer.streamName for streamer in currStreamers)
    currStreamers = []
    async.each followed, getChannelStatus, (err)->
      if not err
        selectedStreamer = null
        labels = []
        console.log 'currstreamers:',currStreamers.length
        for streamer in currStreamers
           ((currStreamer)->
             console.log 'the streamer label:',currStreamer
             labels.push({
               label: currStreamer.displayName
               type: 'normal'
               click: -> openStream(currStreamer)
              })
            )(streamer)

        appIcon.setToolTip('Online streamers');

        if currStreamers.length == 0
          appIcon.setImage(path.join(__dirname, 'img/dota2_gray.jpg'))
          labels.push({
            label: 'No live streams'
            type: 'normal'
          })
        else
          appIcon.setImage(path.join(__dirname, 'img/dota2.png'))

        labels.push({
          label: 'Commands'
          type: 'separator'
        });

        labels.push({
          label: 'Settings'
          type: 'normal'
          click: openSettings
        })

        labels.push({
          label: 'Quit'
          type: 'normal'
          click: 'close'
        })

        console.log 'labels:',labels
        contextMenu = Menu.buildFromTemplate(labels)
        appIcon.setContextMenu(contextMenu)

        for streamer in currStreamers
          notifyNewStreamer(streamer) if not streamerIsAlreadyOnline(streamer)
      else
        console.log 'an error!',err

streamerIsAlreadyOnline = (streamer)->
  console.log 'checking streamer:',streamer,prevStreamers,prevStreamers.indexOf(streamer.streamName) is not -1
  prevStreamers.indexOf(streamer.streamName) > -1

streamWindow = null

openStream = (streamer)->
  console.log 'open stream', streamer
  exec("/usr/local/bin/livestreamer twitch.tv/#{streamer.streamName} best", (error, stdout, stderr)->
    console.log 'exec error: #{error}' if error
  )

dialog = require('dialog')
ipc = require('ipc')

openSetup = ->
  console.log 'open setup'
  setupWindow = new BrowserWindow({
    width: 800
    height: 600
    show: true
  })
  setupUrl = path.join('file://', __dirname, 'setup.html')
  console.log 'setup url:',setupUrl
  setupWindow.loadUrl(setupUrl)

  ipc.on 'saveSetup', (event, arg)->
    if arg
      username = arg
      config.user = username
      fs.writeFile(path.join(__dirname,'/config.json'), JSON.stringify(config), (err)->
        throw err if err
      )
      setupWindow.close() if setupWindow
      setupWindow = null
      tick()
      setInterval( ->
        tick() if username
      , the_interval)

openSettings = ->
  streamWindow = new BrowserWindow({
    width: 800
    height: 600
    show: true
  })
  pageURL = path.join('file://',__dirname,'/settings.html')
  streamWindow.loadUrl(pageURL)
  streamWindow.webContents.on('did-finish-load', ->
    streamWindow.webContents.send('username', username)
  )

  ipc.on 'saveSettings', (event, arg)->
    if arg
      username = arg
      config.user = username
      fs.writeFile(path.join(__dirname,'config.json'), JSON.stringify(config), (err)->
        throw err if err
      )
      streamWindow.close() if streamWindow
      streamWindow = null
      prevStreamers = []
      currStreamers = []
      tick()

app.on 'ready', ->
  console.log 'app is ready'
  fs.readFile(path.join(__dirname, 'config.json'), loadData)
  appIcon = new Tray(path.join(__dirname, 'img/dota2_gray.jpg'))

notifier = require('node-notifier')

notifyNewStreamer = (streamer)->
  notifier.notify({
    title: 'Now Online'
    message: streamer.displayName
    icon: path.join(__dirname, 'img/dota2.png')
  })

close = ->
  streamWindow = null
  appIcon.destroy()
  process.exit(0)
        

      