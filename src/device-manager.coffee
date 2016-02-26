_                = require 'lodash'
ProcessManager   = require './process-manager'
SpawnDevice      = require './spawn-device'
ConnectorManager = require './connector-manager'
debug            = require('debug')('gateblu-service:device-manager')

class DeviceManager
  constructor: ({tmpPath,server,port}) ->
    @processManager   = new ProcessManager {tmpPath}
    @spawnDevice      = new SpawnDevice {tmpPath,server,port}
    @connectorManager = new ConnectorManager {tmpPath}

  start: (device, callback) =>
    debug 'device', device.uuid
    return callback null if @processManager.isRunning device
    connector = _.get device, 'gateblu.connector'
    debug 'starting connector', connector
    return callback null unless connector?
    @connectorManager.installConnector connector, (error) =>
      return callback error if error?
      @spawnDevice.spawn device, callback

  shutdown: (callback=->) =>
    @processManager.killAll callback

module.exports = DeviceManager
