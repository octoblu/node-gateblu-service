class Wrapper
  run: =>
    connectorName = process.env.CONNECTOR
    return @panic 'Missing Connector Name' unless connectorName?
    Connector = require connectorName
    @connector = new Connector()
    @connector.start()
    process.on 'SIGTERM', =>
      console.log 'Stopping device'
      @connector.stop()

  panic: (error) =>
    console.log error if error?
    process.exit 1

new Wrapper().run()
