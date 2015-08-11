'use strict'
#
# CloudMine, Inc
# 2015
#

module.exports = (grunt)->
  grunt.initConfig
    coffee:
      compile:
        expand: true
        cwd: './app'
        src: ['**/*.coffee']
        dest: '_app/'
        ext: '.js'
    copy:
      all:
        files: [
          {
            expand: yes
            cwd: './app/img'
            src: ['**/*.{png,jpg,jpeg,gif,svg}']
            dest: '_app/img'
          },
          {
            expand: yes
            cwd: './app/css'
            src: ['**/*.css']
            dest: '_app/css'
          },
          {
            expand: yes
            cwd: './app/scripts'
            src: ['**/*.js']
            dest: '_app/scripts'
          },
          {
            expand: yes
            cwd: './app/views'
            src: ['**/*.{html, htm}']
            dest: '_app/views'
          },
          {
            expand: yes
            cwd: './'
            src: ['package.json']
            dest: '_app/'
          }
          {
            expand: yes
            cwd: './app'
            src: ['config.json']
            dest: '_app/'
          }
          {
            expand: yes
            mode: yes
            cwd: './node_modules'
            src: ['**/*']
            dest: '_app/node_modules'
          }
        ]
    electron:
      osxBuild:
        options:
          name: 'Watchdog'
          dir: '_app'
          out: 'dist'
          version: '0.30.2'
          platform: 'darwin'
          arch: 'x64'
    chmod:
      options:
        mode: '755'
      notificationTarget:
        src: ['_app/node_modules/node-notifier/vendor/terminal-notifier.app/Contents/MacOS/*']

  require('load-grunt-tasks')(grunt)
  grunt.registerTask 'compile', [
    'coffee'
    'copy'
    'chmod'
    'electron'

  ]
