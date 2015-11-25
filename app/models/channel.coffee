'use strict'

request = require('request')
Q = require('q')

class Channel
  constructor: (@name, @displayName)->
    @stream = null
    @currentGame = null

  onlineStatus: ->
    deferred = Q.defer()
    request "https://api.twitch.tv/kraken/streams/#{@name}", (error, response, body)->
      if not error
        stream = {}
        try
          stream = JSON.parse(body).stream
          @currentGame = stream.game if stream
          deferred.resolve(stream)
        catch err
          console.log 'Error parsing json:', err
          stream = null
          deferred.reject(new Error(err))
    return deferred.promise

module.exports = Channel
