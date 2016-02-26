_              = require 'lodash'
shmock         = require '@octoblu/shmock'
GatebluService = require '../src/gateblu-service'

describe 'GatebluService', ->
  beforeEach ->
    meshbluConfig =
      server: 'localhost'
      port: 0xd00d
      uuid: 'gateblu-uuid'
      token: 'gateblu-token'

    @deviceList =
      getList: sinon.stub()

    @deviceWatcher =
      onConfig: sinon.stub()

    @deviceManager =
      start: sinon.stub()
      shutdown: sinon.stub()

    @meshblu = shmock 0xd00d

    @gatebluAuth = new Buffer('gateblu-uuid:gateblu-token').toString('base64')

    @sut = new GatebluService {meshbluConfig}, {@deviceList, @deviceWatcher, @deviceManager}

  afterEach (done) ->
    @meshblu.close => done()

  describe 'when it has devices and is started', ->
    beforeEach (done) ->
      @getGatebluDevice = @meshblu
        .get '/v2/whoami'
        .set 'Authorization', "Basic #{@gatebluAuth}"
        .reply 200, {
          uuid: 'gateblu-uuid'
          gateblu:
            running: true
        }

      @deviceList.getList.yields null, [
        {uuid: 'superman', type: 'superhero', connector: 'clark-kent', token: 'some-token', gateblu: running: true}
        {uuid: 'spiderman', type: 'superhero', connector: 'peter-parker', token: 'some-token', gateblu: running: true}
        {uuid: 'ironman', type: 'superhero', connector: 'tony-stark', token: 'some-token', gateblu: running: false}
      ]
      @deviceManager.start.yields null
      @sut.start()
      _.delay done, 100

    it 'should get the gateblu device', ->
      @getGatebluDevice.done()

    it 'should listen for changes', ->
      expect(@deviceWatcher.onConfig).to.have.been.called

    it 'should start superman', ->
      superman =
        uuid: 'superman'
        type: 'superhero'
        connector: 'clark-kent'
        token: 'some-token'
        gateblu:
          running: true
      expect(@deviceManager.start).to.have.been.calledWith superman

    it 'should start spiderman', ->
      spiderman =
        uuid: 'spiderman'
        type: 'superhero'
        connector: 'peter-parker'
        token: 'some-token'
        gateblu:
          running: true
      expect(@deviceManager.start).to.have.been.calledWith spiderman

    it 'should not start ironman', ->
      ironman =
        uuid: 'ironman'
        type: 'superhero'
        connector: 'tony-stark'
        token: 'some-token'
        gateblu:
          running: false
      expect(@deviceManager.start).to.not.have.been.calledWith ironman

    describe 'when it gets a config event', ->
      describe 'when it is already running and is still running', ->
        beforeEach (done) ->
          @getGatebluDevice = @meshblu
            .get '/v2/whoami'
            .set 'Authorization', "Basic #{@gatebluAuth}"
            .reply 200, {
              uuid: 'gateblu-uuid'
              gateblu:
                running: true
            }
          @sut._onConfig null, uuid: 'gateblu-uuid'
          _.delay done, 100

        it 'should get the gateblu device', ->
          @getGatebluDevice.done()

        it 'should start superman', ->
          superman =
            uuid: 'superman'
            type: 'superhero'
            connector: 'clark-kent'
            token: 'some-token'
            gateblu:
              running: true
          expect(@deviceManager.start).to.have.been.calledWith superman

        it 'should start spiderman', ->
          spiderman =
            uuid: 'spiderman'
            type: 'superhero'
            connector: 'peter-parker'
            token: 'some-token'
            gateblu:
              running: true
          expect(@deviceManager.start).to.have.been.calledWith spiderman

        it 'should not start ironman', ->
          ironman =
            uuid: 'ironman'
            type: 'superhero'
            connector: 'tony-stark'
            token: 'some-token'
            gateblu:
              running: false
          expect(@deviceManager.start).to.not.have.been.calledWith ironman

  describe 'when it has no devices and is started', ->
    beforeEach (done) ->
      @getGatebluDevice = @meshblu
        .get '/v2/whoami'
        .set 'Authorization', "Basic #{@gatebluAuth}"
        .reply 200, {
          uuid: 'gateblu-uuid'
          gateblu:
            running: true
        }
      @deviceList.getList.yields null, []
      @sut.start()
      _.delay done, 100

    it 'should get the gateblu device', ->
      @getGatebluDevice.done()

    describe 'when it stops running', ->
      beforeEach (done) ->
        @secondGetGatebluDevice = @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{@gatebluAuth}"
          .reply 200, {
            uuid: 'gateblu-uuid'
            gateblu:
              running: false
          }
        @sut._onConfig null, uuid: 'gateblu-uuid'
        _.delay done, 100

      it 'should get the gateblu device', ->
        @secondGetGatebluDevice.done()

      it 'should call deviceManager.shutdown', ->
        expect(@deviceManager.shutdown).to.have.been.called

  describe 'when it has no devices and is not running', ->
    beforeEach (done) ->
      @getGatebluDevice = @meshblu
        .get '/v2/whoami'
        .set 'Authorization', "Basic #{@gatebluAuth}"
        .reply 200, {
          uuid: 'gateblu-uuid'
          gateblu:
            running: false
        }
      @deviceList.getList.yields null, []
      @sut.start()
      _.delay done, 100

    it 'should get the gateblu device', ->
      @getGatebluDevice.done()

    it 'should call deviceManager.shutdown', ->
      expect(@deviceManager.shutdown).to.have.been.called
