fs        = require 'fs-extra'
path      = require 'path'
_         = require 'lodash'
isRunning = require 'is-running'
debug     = require('debug')('gateblu-service:process-manager')

class ProcessManager
  constructor: ({@tmpPath}) ->
    fs.mkdirsSync @getPath()

  getPath: (device) =>
    return path.join @tmpPath, 'pids', device.uuid if device?
    path.join @tmpPath, 'pids'

  exists: (device) =>
    fs.existsSync @getPath device

  get: (device) =>
    fs.readFileSync @getPath device if @exists device

  write: (device, pid) =>
    debug 'writing process file', uuid: device.uuid, pid: pid
    return unless pid?
    fs.writeFileSync @getPath(device), pid

  clear: (device) =>
    debug 'clearing process file', uuid: device.uuid
    fs.unlinkSync @getPath device if @exists device

  isRunning: (device) =>
    pid = @get device
    unless pid?
      @clear device
      return false
    running = isRunning pid
    debug 'process is running', running
    return running

  getAllProcesses: (callback) =>
    items = []
    fs.walk @getPath()
      .on 'data', (item) =>
        uuid = path.basename item.path
        return unless uuid?
        return if uuid = 'pids'
        items.push
          uuid: uuid
      .on 'end', =>
        debug 'got all processes', items
        callback null, items

  kill: (device) =>
    running = @isRunning device
    debug 'maybe killing process', uuid:device.uuid, running:running
    return unless running
    debug 'killing process', uuid: device.uuid
    process.kill @get(device), 'SIGTERM'
    @clear device
    debug 'killed process', uuid: device.uuid

  killAll: (callback) =>
    @getAllProcesses (error, devices) =>
      _.each devices, @kill
      callback()

module.exports = ProcessManager
