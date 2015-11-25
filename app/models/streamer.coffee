'use strict'

class Streamer
  constructor: (name, channel, status)->
    @name = name
    @channel = channel
    @onlineStatus = status
