npm   = require 'npm'
debug = require('debug')('gateblu-service:connector-manager')

class ConnectorManager
  constructor: ({@tmpPath}) ->

  installConnector: (connector, callback=->) =>
    npm.load production: true, =>
      debug 'installConnector', connector, @tmpPath
      npm.commands.install @tmpPath, [connector, 'coffee-script'], callback

module.exports = ConnectorManager
