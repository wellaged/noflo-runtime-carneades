describe 'IFRAME network runtime', ->
  iframe = document.getElementById('network').contentWindow
  origin = window.location.origin
  send = (protocol, command, payload) ->
    iframe.postMessage
      protocol: protocol
      command: command
      payload: payload
    , iframe.location.href
  receive = (expects, done) ->
    listener = (message) ->
      chai.expect(message).to.be.an 'object'
      expected = expects.shift()
      chai.expect(message.data).to.eql expected
      if expects.length is 0
        window.removeEventListener 'message', listener, false
        done()
    window.addEventListener 'message', listener, false

  describe 'Graph Protocol', ->
    describe 'receiving a graph and nodes', ->
      it 'should provide the nodes back', (done) ->
        expects = [
            protocol: 'graph'
            command: 'addnode'
            payload:
              id: 'Foo'
              component: 'core/Repeat'
              metadata:
                hello: 'World'
          ,
            protocol: 'graph'
            command: 'addnode'
            payload:
              id: 'Bar'
              component: 'core/Drop'
              metadata: {}
        ]
        receive expects, done
        send 'graph', 'graph', null
        send 'graph', 'addnode', expects[0].payload
        send 'graph', 'addnode', expects[1].payload
    describe 'receiving an edge', ->
      it 'should provide the edge back', (done) ->
        expects = [
          protocol: 'graph'
          command: 'addedge'
          payload:
            from:
              node: 'Foo'
              port: 'out'
            to:
              node: 'Bar'
              port: 'in'
            metadata:
              route: 5
        ]
        receive expects, done
        send 'graph', 'addedge', expects[0].payload
    describe 'receiving an IIP', ->
      it 'should provide the IIP back', (done) ->
        expects = [
          protocol: 'graph'
          command: 'addinitial'
          payload:
            from:
              data: 'Hello, world!'
            to:
              node: 'Foo'
              port: 'in'
            metadata: {}
        ]
        receive expects, done
        send 'graph', 'addinitial', expects[0].payload

  describe 'Network protocol', ->
    describe 'on starting the network', ->
      it 'should get started', (done) ->
        listener = (message) ->
          chai.expect(message).to.be.an 'object'
          chai.expect(message.data.protocol).to.equal 'network'
          chai.expect(message.data.command).to.equal 'start'
          chai.expect(message.data.payload).to.be.a 'date'
          window.removeEventListener 'message', listener, false
          done()
        window.addEventListener 'message', listener, false
        send 'network', 'start'