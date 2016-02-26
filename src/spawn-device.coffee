ProcessManager = require './process-manager'
_              = require 'lodash'
path           = require 'path'
forever        = require 'forever-monitor'
debug          = require('debug')('gateblu-service:spawn-device')

class SpawnDevice
  constructor: ({@tmpPath,@server,@port}) ->
    @processManager = new ProcessManager {@tmpPath}

  spawn: (device, callback=->) =>
    debug 'spawning child process'
    environment =
      DEBUG: device.gateblu?.DEBUG ? 'nothing'
      MESHBLU_UUID: device.uuid
      MESHBLU_TOKEN: device.token
      MESHBLU_SERVER: @server
      MESHBLU_PORT: @port
      CONNECTOR: device.gateblu?.CONNECTOR ? 'meshblu-shell'

    foreverOptions =
      uid: device.uuid
      max: 1
      silent: true
      args: []
      env: environment
      cwd: @tmpPath
      command: 'node'
      checkFile: false
      killTree: true

    child = new (forever.Monitor)('wrapper.js', foreverOptions)
    child.on 'stderr', (data) =>
      debug 'stderr', device.uuid, data.toString()

    child.on 'stdout', (data) =>
      debug 'stdout', device.uuid, data.toString()

    child.on 'stop', =>
      debug "process for #{device.uuid} stopped."
      @processManager.clear device

    child.on 'exit', =>
      debug "process for #{device.uuid} stopped."
      @processManager.clear device

    child.on 'error', (error) =>
      debug 'error', error

    child.on 'exit:code', (code) =>
      debug 'exit:code', code

    debug 'forever', {uuid: device.uuid, name: device.name}, 'starting'
    child.start()
    pid = _.get child, 'child.pid'
    debug 'spawned process', pid
    @processManager.write device, pid
    callback null

module.exports = SpawnDevice
