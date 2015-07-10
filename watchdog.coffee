'use strict'
#
# Watchdog Media
# 2015
#
pkg = require('./package.json')
app = require('app')
BrowserWindow = require('browser-window')
Menu = require('menu')
Tray = require('tray')
request = require('request')
async = require('async')
path = require('path')
exec = require('child_process').exec
fs = require('fs')
User = require('./models/user.js')
Q = require('q')
Channel = require('./models/channel.js')

# Watchdog Settings
version = pkg.version
console.log 'Running version',version

# Get a list of followed
followed = []
currStreamers = []
prevStreamers = []

# Keep a global reference of the window object, if you don't, the window will
# be closed automatically when the javascript object is GCed
mainWindow = null
appIcon = null
user = null
minutes = .5
the_interval = minutes * 60 * 1000
config = {}
setupWindow = {}

loadData = (err, data)->
  if not err
    config = JSON.parse(data)
    username = config.user
    if username
      user = new User(username)
      tick()
      setInterval( ->
        tick() if user
      , the_interval)
    else
      openSetup()
  else
    console.log 'Error reading configuration:',err

contextMenu = {} # We don't want a new menu every time

tick = ->
  prevStreamers = []

  user.getFollowed().then (results)->
    console.log 'currStreamers:',currStreamers
    prevStreamers = (streamer.channel.name for streamer in currStreamers)
    currStreamers = []
    gameMap = {}
    labels = []

    async.each results, (channel, callback)->
      currChannel = new Channel(channel.streamName, channel.displayName)
      currChannel.onlineStatus().then (stream)->
        console.log 'THE STREAM:::',stream
        currStreamers.push(stream) if stream
        callback()
    , (err)->
      if not err
        selectedStreamer = null

        console.log 'currstreamers:',currStreamers.length, currStreamers
        for streamer in currStreamers
          console.log 'STREAMER::', streamer
          ((currStreamer)->
            console.log 'the streamer label:',currStreamer.display_name, currStreamer.channel
            if gameMap[currStreamer.game] then gameMap[currStreamer.game].push(currStreamer) else gameMap[currStreamer.game] = [currStreamer]
          )(streamer.channel)

        appIcon.setToolTip('Online streamers');

        if currStreamers.length == 0
          appIcon.setImage(path.join(__dirname, 'img/WatchDog-Menu-Inactive.png'))
          labels.push({
            label: 'No live streams'
            type: 'normal'
          })
        else
          appIcon.setImage(path.join(__dirname, 'img/WatchDog-Menu-Active.png'))

        console.log 'gameMap:',gameMap

        createMenu(gameMap, labels)

        for streamer in currStreamers
          notifyNewStreamer(streamer) if not streamerIsAlreadyOnline(streamer)
      else
        console.log 'an error!',err

streamerIsAlreadyOnline = (streamer)->
  console.log 'checking streamer:',streamer,prevStreamers,prevStreamers.indexOf(streamer.streamName) is not -1
  prevStreamers.indexOf(streamer.channel.name) > -1

streamWindow = null

createMenu = (gameMap, labels)->
  # Create Menu
  for key in Object.keys(gameMap)
    gameMap[key].sort (a,b)->
      return -1 if a.display_name < b.display_name
      return 1 if a.display_name > b.display_name
      0

    labels.push({
      label: key
      enabled: false
    })

    for streamer in gameMap[key]
      ((streamer)->
        labels.push({
          label: streamer.display_name
          type: 'normal'
          click: -> openStream(streamer.name)
        })
      )(streamer)
    labels.push({
      type: 'separator'
    })

  labels.push({
    label: 'Settings'
    type: 'normal'
    click: openSettings
  })

  labels.push({
    label: 'Quit'
    type: 'normal'
    click: close
  })

  contextMenu = Menu.buildFromTemplate(labels)
  appIcon.setContextMenu(contextMenu)

openStream = (streamer)->
  loadingSplash = new BrowserWindow({ width: 400, height: 300, show: true, type: 'splash', center: true});
  loadingSplash.loadUrl(path.join('file://', __dirname, '/views/loading.html'))

  setTimeout( ->
    loadingSplash.destroy();
  , 3000)

  exec "/usr/local/bin/livestreamer twitch.tv/#{streamer} best", (error, stdout, stderr)->
      console.log "exec error: #{error}" if error
      if error
        errorWindow = new BrowserWindow({
          width: 400
          height: 300
          show: true
        })
        errorUrl = path.join('file://', __dirname, '/views/error.html')
        errorWindow.loadUrl(errorUrl)

dialog = require('dialog')
ipc = require('ipc')

openSetup = ->
  setupWindow = new BrowserWindow({
    width: 800
    height: 600
    show: true
  })
  setupUrl = path.join('file://', __dirname, '/views/setup.html')
  setupWindow.loadUrl(setupUrl)

  ipc.on 'saveSetup', (event, arg)->
    if arg
      username = arg
      config.user = username
      config.lastUpdate = Date.now()
      console.log 'setting config: ',config
      user = new User(username)
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
  pageURL = path.join('file://',__dirname,'/views/settings.html')
  streamWindow.loadUrl(pageURL)
  streamWindow.webContents.on('did-finish-load', ->
    streamWindow.webContents.send('settingsData', {username: user.username, version: version, lastUpdate: config.lastUpdate})
  )

  ipc.on 'saveSettings', (event, arg)->
    if arg
      username = arg
      config.user = username
      user = new User(username)
      fs.writeFile(path.join(__dirname,'config.json'), JSON.stringify(config), (err)->
        throw err if err
      )
      streamWindow.close() if streamWindow
      streamWindow = null
      prevStreamers = []
      currStreamers = []
      tick()

app.on 'ready', ->
  fs.readFile(path.join(__dirname, 'config.json'), loadData)
  appIcon = new Tray(path.join(__dirname, 'img/WatchDog-Menu-Inactive.png'))

notifier = require('node-notifier')

notifyNewStreamer = (streamer)->
  console.log 'NOTIFY',streamer
  notifier.notify({
    title: 'Now Online'
    message: streamer.channel.display_name
    icon: path.join(__dirname, 'img/WatchDog-Menu-Active.png')
  })

close = ->
  streamWindow = null
  appIcon.destroy()
  process.exit(0)
