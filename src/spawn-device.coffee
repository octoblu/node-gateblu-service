ProcessManager = require './process-manager'
_              = require 'lodash'
path           = require 'path'
forever        = require 'forever-monitor'
debug          = require('debug')('gateblu-service:spawn-device')

class SpawnDevice
  constructor: ({@buildPath,@server,@port}) ->
    @processManager = new ProcessManager {@buildPath}

  spawn: (device, callback=->) =>
    deviceDebug = require('debug')("gateblu-service:device:#{device.uuid}")
    debug 'spawning child process'
    gateblu = device.gateblu ? {}
    environment =
      DEBUG: gateblu.DEBUG ? "#{gateblu.connector}*"
      MESHBLU_UUID: device.uuid
      MESHBLU_TOKEN: device.token
      MESHBLU_SERVER: @server
      MESHBLU_PORT: @port
      CONNECTOR: gateblu.connector

    debug 'device env', environment
    foreverOptions =
      uid: device.uuid
      max: 1
      silent: true
      args: []
      env: environment
      cwd: @buildPath
      command: 'node'
      checkFile: false
      killTree: true

    child = new (forever.Monitor)('wrapper.js', foreverOptions)
    child.on 'stderr', (data) =>
      deviceDebug 'stderr', data.toString()

    child.on 'stdout', (data) =>
      deviceDebug 'stdout', data.toString()

    child.on 'stop', =>
      deviceDebug 'process stopped.'
      @processManager.clear device

    child.on 'exit', =>
      deviceDebug 'process stopped.'
      @processManager.clear device

    child.on 'error', (error) =>
      deviceDebug 'error', error

    child.on 'exit:code', (code) =>
      deviceDebug 'exit:code', code

    debug 'forever', {uuid: device.uuid, name: device.name}, 'starting'
    child.start()
    pid = _.get child, 'child.pid'
    debug 'spawned process', pid
    @processManager.write device, pid
    callback null

module.exports = SpawnDevice
