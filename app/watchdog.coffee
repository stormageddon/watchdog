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
Streamer = require('./models/streamer.js')
Q = require('q')
Channel = require('./models/channel.js')
autoUpdater = require('auto-updater')
open = require('open')

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
    username = config.user?.username

    if username
      console.log 'should notify', config.user.shouldNotify
      user = new User(username, {shouldNotify: config.user.shouldNotify})
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
    prevStreamers = (streamer.channel.name for streamer in currStreamers)
    currStreamers = []
    gameMap = {}
    labels = []

    async.each results, (channel, callback)=>
      currChannel = new Channel(channel.streamName, channel.displayName)
      currChannel.onlineStatus().then (stream)->
        currStreamers.push(stream) if stream
        callback()
        return
    , (err)->
      if not err
        selectedStreamer = null

        for streamer in currStreamers
          ((currStreamer)->
            if gameMap[currStreamer.game] then gameMap[currStreamer.game].push(currStreamer) else gameMap[currStreamer.game] = [currStreamer]
          )(streamer.channel)
        appIcon.setToolTip('Online streamers');

        if currStreamers.length == 0
          appIcon.setImage(path.join(__dirname, 'img/WatchDog-Menu-Inactive.png'))
          labels.push({
            label: 'No live streams'
            enabled: false
          })

          labels.push({
            type: 'separator'
          })
        else
          appIcon.setImage(path.join(__dirname, 'img/WatchDog-Menu-Active.png'))


        createMenu(gameMap, labels)

        for streamer in currStreamers
          notifyNewStreamer(streamer) if not streamerIsAlreadyOnline(streamer)

      else
        console.log 'an error!',err



  , (error)->
    console.log 'error was thrown:', error

streamerIsAlreadyOnline = (streamer)->
  prevStreamers.indexOf(streamer.channel.name) > -1

streamWindow = null

createMenu = (gameMap = {}, labels = [])->
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
        }) if streamer.display_name not in labels
      )(streamer)
    labels.push({
      type: 'separator'
    })

  labels.push({
    label: 'Preferences'
    type: 'normal'
    click: openSettings
  })

  labels.push({
    label: 'About'
    type: 'normal'
    click: openAbout
  })

  labels.push({
    label: 'Quit'
    type: 'normal'
    click: close
  })

  labels.push({
    type: 'separator'
  })

  labels.push({
    label: 'Update available!'
    type: 'normal'
    click: openUpdate
  }) if isOutdated

  labels.push({
    label: 'Watchdog is up to date'
    enabled: false
  }) if not isOutdated

  contextMenu = Menu.buildFromTemplate(labels)
  appIcon.setContextMenu(contextMenu)

isOutdated = false

openUpdate = ->
  open 'http://stormageddon.github.io', (err)->
    console.log 'an error:',err if err

openAbout = ->
  aboutWindow = new BrowserWindow({ width: 400, height: 300, show: true, center: true })
  aboutWindow.loadUrl(path.join('file://', __dirname, '/views/about.html'))
  aboutWindow.webContents.on 'did-finish-load', ->
    aboutWindow.webContents.send('versionData', {version: version})

openStream = (streamer)->
  loadingSplash = new BrowserWindow({ width: 400, height: 300, show: true, type: 'splash', center: true, frame: false});
  loadingSplash.loadUrl(path.join('file://', __dirname, '/views/loading.html'))

  child = exec "/usr/local/bin/livestreamer twitch.tv/#{streamer} best", (error, stdout, stderr)->
      console.log "exec error: #{error}" if error
      if error
        # Hacky way to try again with Livestreamer on path (mostly for windows)
        child = exec "livestreamer twitch.tv/#{streamer} best", (error, stdout, stderr)->
          if error #display error if it is still failing
            errorWindow = new BrowserWindow({
              width: 400
              height: 300
              show: true
            })
            errorUrl = path.join('file://', __dirname, '/views/error.html')
            errorWindow.loadUrl(errorUrl)
            loadingSplash.destroy()
  child.stdout.on 'data', (data) -> loadingSplash.destroy() if data.toString().includes('Starting player') or data.toString().includes('Renderer process started')

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
      newUser = new User(arg.username, {shouldNotify: true, lastUpdate: Date.now()})
      newUser.getFollowed().then (data)->
        user = newUser
        username = arg
        config.user = {username: username}
        config.lastUpdate = Date.now()
        config.user.shouldNotify = yes
        json = JSON.stringify(config)
        fs.writeFile(path.join(__dirname,'/config.json'), json, (err)->
          throw err if err
          console.log 'wrote config to file', config
          setupWindow.close() if setupWindow
          setupWindow = null
          tick()
          setInterval( ->
            tick() if username
          , the_interval)
        )
      , (error)->
        setupWindow.webContents.send('error', error.message) if error.status is 404
    else
      setupWindow.webContents.send('error', 'Username is required')

openSettings = ->
  streamWindow = new BrowserWindow({
    width: 600
    height: 300
    show: true
  })
  pageURL = path.join('file://',__dirname,'/views/settings.html')
  streamWindow.loadUrl(pageURL)
  streamWindow.webContents.on('did-finish-load', ->
    streamWindow.webContents.send('settingsData', {username: user.username, version: version, lastUpdate: config.lastUpdate, shouldNotify: user.settings.shouldNotify})
  )

  ipc.on 'saveSettings', (event, arg)->
    if arg
      newUser = new User(arg.username, {shouldNotify: arg.shouldNotify})
      newUser.settings.save()
      prevStreamers = []
      currStreamers = []

      newUser.getFollowed().then (data)->
        username = arg.username
        config.user = {username: username}
        config.user.shouldNotify = newUser.settings.shouldNotify
        console.log 'writing to config file:', config
        user = newUser
        streamWindow.close() if streamWindow
        streamWindow = null

        fs.writeFile path.join(__dirname,'config.json'), JSON.stringify(config), (err)->
          throw err if err

        tick()
      , (error)->
        console.log "User fetch error",error

        streamWindow.webContents.send('error', error.message) if error.status is 404
    else
      streamWindow.webContents.send('error', 'Username is required')

app.on 'ready', ->
  app.dock.hide()
  fs.readFile(path.join(__dirname, 'config.json'), loadData)
  appIcon = new Tray(path.join(__dirname, 'img/WatchDog-Menu-Inactive.png'))
  createMenu() # Create an empty menu immediately

  require('events').EventEmitter

  request "http://168.235.69.244:3498/latest?version=#{version}", (error, response, body)->
    if not error
      try
        data = JSON.parse(body)
        if data.statusCode is 200
          isOutdated = true
    console.log 'error fetching version:',error if error

notifier = require('node-notifier')

notifyNewStreamer = (streamer)->
  return if not user.settings.shouldNotify

  notifier.notify( {
    title: 'Now Online'
    message: streamer.channel.display_name
    sender: 'com.github.electron'
  }, (err)->
    console.log 'err:',err if err
  )


close = ->
  app.quit()
