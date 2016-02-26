_             = require 'lodash'
async         = require 'async'
MeshbluHttp   = require 'meshblu-http'
DeviceList    = require 'meshblu-device-list'
DeviceWatcher = require 'meshblu-device-watcher'
DeviceManager = require './device-manager'
debug         = require('debug')('gateblu-service:gateblu-service')

class GatebluService
  constructor: ({meshbluConfig,tmpPath}, dependencies={}) ->
    @deviceList = dependencies.deviceList ? new DeviceList {meshbluConfig}
    @deviceWatcher = dependencies.deviceWatcher ? new DeviceWatcher {meshbluConfig}
    @deviceManager = dependencies.deviceManager ? new DeviceManager {tmpPath,server:meshbluConfig.server,port:meshbluConfig.port}
    @meshbluHttp = new MeshbluHttp meshbluConfig

  start: =>
    @deviceWatcher.onConfig @_onConfig
    @update()

  update: =>
    debug 'updating'
    @meshbluHttp.whoami (error, device) =>
      return @_printError error if error?
      debug 'got whoami', device.gateblu?.running
      return @deviceManager.shutdown() unless device.gateblu?.running
      debug 'getting list'
      @deviceList.getList (error, devices) =>
        debug 'got list of devices'
        return @_printError error if error?
        devices = _.filter devices, (device) => device.gateblu?.running
        async.eachSeries devices, @deviceManager.start, (error) =>
          return @_printError error if error?
          debug 'started devices'

  _printError: (error) =>
    console.error 'Error in Gateblu Service'
    console.error error?.stack ? error?.message ? error if error?

  _onConfig: (error, config) =>
    debug 'got config'
    return console.error error if error?
    @update()

module.exports = GatebluService
