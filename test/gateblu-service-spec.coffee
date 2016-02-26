_              = require 'lodash'
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

    @sut = new GatebluService {meshbluConfig}, {@deviceList, @deviceWatcher, @deviceManager}

  describe 'when it has devices and is started', ->
    beforeEach (done) ->
      @deviceList.getList.yields null, [
        {uuid: 'superman', type: 'superhero', connector: 'clark-kent', token: 'some-token', gateblu: running: true}
        {uuid: 'spiderman', type: 'superhero', connector: 'peter-parker', token: 'some-token', gateblu: running: true}
        {uuid: 'ironman', type: 'superhero', connector: 'tony-stark', token: 'some-token', gateblu: running: false}
      ]
      @deviceManager.start.yields null
      @sut.start()
      _.delay done, 100

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
      beforeEach (done) ->
        @deviceWatcher.onConfig.yields null, uuid: 'gateblu-uuid'
        _.delay done, 100

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
