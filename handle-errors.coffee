_      = require 'lodash'
colors = require 'colors'

class HandleErrors
  constructor: (@shutdown=->)->

  run: =>
    process.once 'exit', @die

    process.once 'SIGINT', =>
      console.log colors.cyan '[SIGINT] Gracefully cleaning up...'
      process.stdin.resume()
      @shutdown =>
        console.error colors.magenta 'Gateblu is now shutdown...'
        process.exit 0

    process.once 'SIGTERM', =>
      console.log colors.cyan '[SIGTERM] Gracefully cleaning up...'
      process.stdin.resume()
      @shutdown =>
        console.error colors.magenta 'Gateblu is now shutdown...'
        process.exit 0

    process.once 'uncaughtException', (error) =>
      console.error 'Uncaught Exception', error
      @die error

  die: (error) =>
    @shutdown =>
      console.error colors.magenta 'Gateblu is now shutdown...'
      @consoleError error
      console.error colors.red 'Gateblu shutdown'
      process.exit 1

  consoleError: (error) =>
    return unless error
    return console.error error unless _.isError error

    console.error colors.red error.message
    console.error error.stack

module.exports = HandleErrors
