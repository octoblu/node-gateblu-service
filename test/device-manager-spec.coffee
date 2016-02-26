path           = require 'path'
DeviceManager  = require '../src/device-manager'
ProcessManager = require '../src/process-manager'

describe 'DeviceManager', ->
  beforeEach ->
    tmpPath = path.join __dirname, '..', 'tmp'
    @processManager = new ProcessManager {tmpPath}
    @sut = new DeviceManager {tmpPath,server:'localhost',port:0xd00d}

  afterEach (done) ->
    @sut.shutdown done

  describe 'when nothing is running', ->
    it 'should not have spiderman running', ->
      expect(@processManager.isRunning uuid: 'spiderman').to.be.false

    it 'should not have any processes', (done) ->
      @processManager.getAllProcesses (error, items) =>
        return done error if error?
        expect(items).to.be.empty
        done()

  describe 'when a device is started', ->
    beforeEach (done) ->
      spiderman =
        uuid: 'spiderman'
        type: 'superhero'
        connector: 'peter-parker'
        token: 'some-token'
        gateblu:
          running: true
          connector: 'gateblu-test-connector'

      @sut.start spiderman, (error) =>
        @firstPid = @processManager.get spiderman
        done error

    describe 'when auto shutdown', ->
      it 'should write a pid file', ->
        expect(@processManager.exists {uuid: 'spiderman'}).to.be.true

      it 'should the process should be running', ->
        expect(@processManager.isRunning {uuid: 'spiderman'}).to.be.true

      describe 'when the device is started again', ->
        beforeEach (done) ->
          spiderman =
            uuid: 'spiderman'
            type: 'superhero'
            connector: 'peter-parker'
            token: 'some-token'
            gateblu:
              running: true
              connector: 'gateblu-test-connector'

          @sut.start spiderman, (error) =>
            @secondPid = @processManager.get spiderman
            done error

        it 'should not change the pid', ->
          expect(@firstPid).to.equal @secondPid

  describe 'when a device is start but is missing the connector', ->
    beforeEach (done) ->
      spiderman =
        uuid: 'spiderman'
        type: 'superhero'
        connector: 'peter-parker'
        token: 'some-token'
        gateblu:
          running: true

      @sut.start spiderman, (@error) => done()

    it 'should not have error', ->
      expect(@error).to.not.exist

    it 'should not write a pid file', ->
      expect(@processManager.exists {uuid: 'spiderman'}).to.be.false

    it 'should the process should not be running', ->
      expect(@processManager.isRunning {uuid: 'spiderman'}).to.be.false
