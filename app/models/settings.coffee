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
    console.log 'THE SETTINGS:', JSON.stringify(this)
#    fs.writeFile.path.join(__dirname, 'config.json'), JSON.stringify(this)
#

module.exports = Settings
