'use strict'

request = require('request')
Q = require('q')

class User
  constructor: (@username)->
    @followed = []

  getFollowed: ->
    console.log 'getting followed'
    deferred = Q.defer()
    request "https://api.twitch.tv/kraken/users/#{@username}/follows/channels", (error, response, body)->
      if not error
        data = JSON.parse(body)
        console.log 'data:',data
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
