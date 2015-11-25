'use strict'

request = require('request')
Settings = require('./Settings')
Q = require('q')
FETCH_LIMIT = 100 # After 100, we will need to paginate via the twitch api

class User
  constructor: (username, settings = {shouldNotify: true})->
    @username = username
    @followed = []
    settings.username = username
    @settings = new Settings(settings)

  getFollowed: ->
    deferred = Q.defer()
    request "https://api.twitch.tv/kraken/users/#{@username}/follows/channels?limit=#{FETCH_LIMIT}", (error, response, body)->
      if not error
        try
          data = JSON.parse(body)
        catch error
          deferred.reject(body)
        if data
          if not data.error
            @followed = ({streamName:streamer.channel.name, displayName:streamer.channel.display_name} for streamer in data.follows)
            deferred.resolve(@followed)
          else
            deferred.reject(data)
      else
        deferred.reject(new Error(error))
    return deferred.promise

module.exports = User
