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
            cwd: './node_modules'
            src: ['**/*']
            dest: '_app/node_modules'
          }
          {
            expand: yes
            cwd: './lib'
            src: ['*']
            dest: '_app/lib'
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

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-electron'
  grunt.registerTask 'compile', [
    'coffee'
    'copy'
    'electron'
  ]
