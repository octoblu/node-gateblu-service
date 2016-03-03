path           = require 'path'
MeshbluConfig  = require 'meshblu-config'
GatebluService = require './src/gateblu-service'
HandleErrors   = require './handle-errors'
debug          = require('debug')('gateblu-service:command')

class Command
  run: =>
    debug 'running'
    buildPath = process.env.GATEBLU_BUILD_PATH ? path.join __dirname, 'build'
    meshbluJSONFile = path.join(buildPath, 'meshblu.json')
    meshbluConfig = new MeshbluConfig({filename: meshbluJSONFile}).toJSON()
    return @die new Error("Missing Meshblu Config. Should be here, #{meshbluJSONFile}") unless meshbluConfig.uuid
    debug 'starting up service', meshbluConfig.uuid
    service = new GatebluService {meshbluConfig, buildPath}
    service.start()
    new HandleErrors(service.shutdown).run()

  die: (error) =>
    console.error error.stack
    process.exit 1

new Command().run()
