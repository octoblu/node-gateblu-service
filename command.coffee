_              = require 'lodash'
fs             = require 'fs-extra'
path           = require 'path'
GatebluService = require './src/gateblu-service'
MeshbluConfig  = require 'meshblu-config'
MeshbluHttp    = require 'meshblu-http'
HandleErrors   = require './handle-errors'
packageJSON    = require './package.json'
debug          = require('debug')('gateblu-service:command')

CONFIG_PATH = process.env.MESHBLU_JSON_FILE ? './meshblu.json'
OPTIONS =
  nodePath: process.env.GATEBLU_NODE_PATH ? path.join __dirname, ''
  tmpPath: process.env.GATEBLU_TMP_PATH ? path.join __dirname, './tmp'
  server: process.env.GATEBLU_SERVER ? 'meshblu.octoblu.com'
  port: process.env.GATEBLU_PORT ? 443

class Command
  run: =>
    debug 'running'
    meshbluConfig = @getConfig()
    @verify meshbluConfig, (error) =>
      meshbluConfig = @getConfig()
      debug 'starting up service', meshbluConfig.uuid
      service = new GatebluService {meshbluConfig}
      service.start()
      new HandleErrors(service.shutdown).run()

  registerGateblu: (meshbluConfig, callback=->) =>
    meshbluHttp = new MeshbluHttp server: meshbluConfig.server, port: meshbluConfig.port
    properties =
      type: 'device:gateblu'
      devices: []
      gateblu:
        running: true
        version: packageJSON.version
    meshbluHttp.register properties, (error, device) =>
      debug 'registered gateblu', error
      return callback error if error?
      config = _.pick device, 'uuid', 'token', 'server', 'port'
      config.server = meshbluConfig.server
      config.port = meshbluConfig.port
      @writeConfig config
      callback null

  verify: (meshbluConfig, callback) =>
    debug 'verifying device'
    return callback null, meshbluConfig if meshbluConfig.uuid? and meshbluConfig.token?
    @registerGateblu meshbluConfig, callback

  getConfig: =>
    config = new MeshbluConfig {filename: CONFIG_PATH}
    json = config.toJSON()
    _.defaults json, OPTIONS

  writeConfig: (meshbluConfig) =>
    debug 'saveOptions', meshbluConfig
    fs.mkdirpSync path.dirname(CONFIG_PATH)
    fs.writeFileSync CONFIG_PATH, JSON.stringify(meshbluConfig, true, 2)

new Command().run()
