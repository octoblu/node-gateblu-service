path           = require 'path'
MeshbluConfig  = require 'meshblu-config'
GatebluService = require './src/gateblu-service'
HandleErrors   = require './handle-errors'
debug          = require('debug')('gateblu-service:command')



class Command
  run: =>
    debug 'running'
    buildPath = process.env.MESHBLU_BUILD_PATH ? path.join __dirname, 'build'

    meshbluConfig = new MeshbluConfig({filename: path.join(buildPath, 'meshblu.json')}).toJSON()
    debug 'starting up service', meshbluConfig.uuid
    service = new GatebluService {meshbluConfig, buildPath}
    service.start()
    new HandleErrors(service.shutdown).run()

new Command().run()
