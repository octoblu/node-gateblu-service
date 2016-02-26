ProcessManager = require './process-manager'
SpawnDevice    = require './spawn-device'

class DeviceManager
  constructor: ({tmpPath,server,port}) ->
    @processManager = new ProcessManager {tmpPath}
    @spawnDevice    = new SpawnDevice {tmpPath,server,port}

  start: (device, callback) =>
    return callback null if @processManager.isRunning device
    @spawnDevice.spawn device, callback

  shutdown: (callback) =>
    @processManager.killAll callback

module.exports = DeviceManager
