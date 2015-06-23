'use strict'

request = require('request')
Q = require('q')

class Channel
  constructor: (@name, @displayName)->
    @stream = null

  onlineStatus: ->
    console.log 'getting status of channel'
    deferred = Q.defer()
    request "https://api.twitch.tv/kraken/streams/#{@name}", (error, response, body)->
      if not error
        stream = {}
        try
          stream = JSON.parse(body).stream
          console.log 'resolving stream:',stream
          deferred.resolve(stream)
        catch err
          console.log 'Error parsing json:', err
          stream = null
          deferred.reject(new Error(err))
    return deferred.promise

module.exports = Channel
