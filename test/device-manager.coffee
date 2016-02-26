path           = require 'path'
DeviceManager  = require '../src/device-manager'
ProcessManager = require '../src/process-manager'

describe 'DeviceManager', ->
  beforeEach ->
    tmpPath = path.join __dirname, '..', 'tmp'
    @processManager = new ProcessManager {tmpPath}
    @sut = new DeviceManager {tmpPath,server:'localhost',port:0xd00d}

  describe 'when a device is started', ->
    beforeEach (done) ->
      spiderman =
        uuid: 'spiderman'
        type: 'superhero'
        connector: 'peter-parker'
        token: 'some-token'
        gateblu:
          running: true

      @sut.start spiderman, (error) =>
        @firstPid = @processManager.get spiderman
        done error

    describe 'when auto shutdown', ->
      afterEach (done) ->
        @sut.shutdown => done()

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

          @sut.start spiderman, (error) =>
            @secondPid = @processManager.get spiderman
            done error

        it 'should not change the pid', ->
          expect(@firstPid).to.equal @secondPid

    describe 'when shutdown', ->
      beforeEach (done) ->
        @sut.shutdown => done()

      it 'should not have any processes', (done) ->
        @processManager.getAllProcesses (error, items) =>
          return done error if error?
          expect(items).to.be.empty
          done()
