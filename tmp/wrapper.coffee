_  = require 'lodash'
class Wrapper
  run: =>
    setInterval =>
      n = 0
    , 1000


new Wrapper().run()
