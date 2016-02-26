_     = require 'lodash'
fs    = require 'fs-extra'
npm   = require 'npm'
path  = require 'path'
debug = require('debug')('gateblu-service:connector-manager')

class ConnectorManager
  constructor: (@installPath, @connector, dependencies={}) ->
    @connectorDir = path.join @installPath, 'node_modules', @connector

  installConnector: (callback=->) =>
    npm.load production: true, =>
      debug 'installConnector', @connector, @installPath
      npm.commands.install @installPath, [@connector], (error) =>
        callback error

module.exports = ConnectorManager
