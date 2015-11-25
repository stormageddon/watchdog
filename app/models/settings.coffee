'use strict'

fs = require('fs')

class Settings
  constructor: (opts)->
    {
      @username
      @lastUpdate
      @shouldNotify
    } = opts


  save: ->
    this

module.exports = Settings
