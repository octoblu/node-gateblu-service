npm   = require 'npm'
debug = require('debug')('gateblu-service:connector-manager')
debugStream = require('debug-stream')(debug)

class ConnectorManager
  constructor: ({@buildPath}) ->

  installConnector: (connector, callback=->) =>
    config =
      production: true,
      progress: false,
      logstream: debugStream()

    npm.load config, (error) =>
      return callback error if error?
      debug 'installConnector', connector, @buildPath
      npm.commands.install @buildPath, [connector], (error) => callback error
      npm.registry.log.on 'log', (message) =>
        return if message.prefix == 'attempt'
        debug message.level, message.messageRaw... if message.level == 'info'

module.exports = ConnectorManager
