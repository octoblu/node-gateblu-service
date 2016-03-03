MeshbluConfig = require 'meshblu-config'
MeshbluHttp   = require 'meshblu-http'
DeviceWatcher = require 'meshblu-device-watcher'

class Wrapper
  run: =>
    connectorName = process.env.CONNECTOR
    connectorPath = process.env.CONNECTOR_PATH ? __dirname
    connectorFullPath = path.join(connectorPath, connectorName)
    return @panic 'Missing Connector Name' unless connectorName?
    packageJSON = require "#{connectorName}/package.json"
    return @runNew(connectorName) if packageJSON.isSimpleConnector
    return @runOld(connectorName)

  runOld: (connectorName) =>
    @getDevice (error, device) =>
      return console.log 'Device not running' unless device.gateblu?.running
      require "#{connectorFullPath}/command.js"
      console.log 'Started old device'
      process.on 'SIGTERM', =>
        console.log 'Stopping old device'
        process.exit 0

  runNew: (connectorName)=>
    Connector = require connectorFullPath

    connector = new Connector()

    deviceWatcher = new DeviceWatcher @getMeshbluConfig()
    deviceWatcher.onConfig (error, device) =>
      return console.log error if error?
      connector.update device

    @getDevice (error, device) =>
      return console.log 'Device not running' unless device.gateblu?.running
      connector.start device, =>
        console.log 'Started new device'

    process.on 'SIGTERM', =>
      console.log 'Stopping new device'
      connector.stop =>
        process.exit 0

  getMeshbluConfig: =>
    return new MeshbluConfig({}).toJSON()

  getDevice: (callback) =>
    meshbluHttp = new MeshbluHttp @getMeshbluConfig()
    meshbluHttp.whoami callback

  panic: (error) =>
    console.log error if error?
    process.exit 1

new Wrapper().run()
