path          = require 'path'
DeviceManager = require '../src/device-manager'
ProcessManager = require '../src/process-manager'

describe 'DeviceManager', ->
  beforeEach ->
    tmpPath = path.join __dirname, '..', 'tmp'
    @processManager = new ProcessManager {tmpPath}
    @sut = new DeviceManager {tmpPath,server:'localhost',port:0xd00d}

  afterEach (done) ->
    @sut.shutdown => done()

  describe 'when a device is started', ->
    beforeEach (done) ->
      spiderman =
        uuid: 'spiderman'
        type: 'superhero'
        connector: 'peter-parker'
        token: 'some-token'
        gateblu:
          running: true

      @sut.start spiderman, (error) => done error

    it 'should write a pid file', ->
      expect(@processManager.exists {uuid: 'spiderman'}).to.be.true

    it 'should the process should be running', ->
      expect(@processManager.isRunning {uuid: 'spiderman'}).to.be.true
