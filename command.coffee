path           = require 'path'
MeshbluConfig  = require 'meshblu-config'
GatebluService = require './src/gateblu-service'
HandleErrors   = require './handle-errors'
debug          = require('debug')('gateblu-service:command')

CONFIG_PATH = process.env.MESHBLU_JSON_FILE ? path.join __dirname, 'meshblu.json'
TMP_PATH = process.env.MESHBLU_TMP_PATH ? path.join __dirname, 'tmp'

class Command
  run: =>
    debug 'running'
    meshbluConfig = new MeshbluConfig({filename: CONFIG_PATH}).toJSON()
    meshbluConfig.tmpPath = TMP_PATH unless meshbluConfig.tmpPath
    debug 'starting up service', meshbluConfig.uuid, meshbluConfig.tmpPath
    service = new GatebluService {meshbluConfig}
    service.start()
    new HandleErrors(service.shutdown).run()
    
new Command().run()
