_                = require 'lodash'
ProcessManager   = require './process-manager'
SpawnDevice      = require './spawn-device'
ConnectorManager = require './connector-manager'
debug            = require('debug')('gateblu-service:device-manager')

class DeviceManager
  constructor: ({buildPath,meshbluConfig}) ->
    {server, port} = meshbluConfig
    @processManager   = new ProcessManager {buildPath}
    @spawnDevice      = new SpawnDevice {buildPath,server,port}
    @connectorManager = new ConnectorManager {buildPath}

  start: (device, callback) =>
    debug 'device', device.uuid
    return callback null if @processManager.isRunning device
    connector = _.get device, 'gateblu.connector'
    debug 'starting connector', connector
    return callback null unless connector?
    @connectorManager.installConnector connector, (error) =>
      debug 'installed connector', error: error
      return callback error if error?
      @spawnDevice.spawn device, callback

  shutdown: (callback=->) =>
    @processManager.killAll callback

module.exports = DeviceManager
