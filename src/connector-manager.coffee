npm   = require 'npm'
debug = require('debug')('gateblu-service:connector-manager')
debugStream = require('debug-stream')(debug)

class ConnectorManager
  constructor: ({@tmpPath}) ->

  installConnector: (connector, callback=->) =>
    config =
      production: true,
      progress: false,
      logstream: debugStream()

    npm.load config, (error) =>
      return callback error if error?
      debug 'installConnector', connector, @tmpPath
      packages = [connector, 'coffee-script', 'meshblu-config', 'meshblu-http']
      npm.commands.install @tmpPath, packages, (error) => callback error
      npm.registry.log.on 'log', (message) =>
        return if message.prefix == 'attempt'
        debug message.level, message.messageRaw... if message.level == 'info'

module.exports = ConnectorManager
