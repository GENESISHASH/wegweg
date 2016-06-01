# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
require('iced-coffee-script').register()
_ = require 'lodash'

module.exports = wegweg = (opt={}) ->

  unless (opt?.globals? and opt.globals is false)
    process.setMaxListeners 0

    root.log ?= (x...) -> try console.log x...

    unless (opt?.shelljs? and opt.shelljs is false)
      require 'shelljs/global'

  _.cmap = (x...) ->
    _.compact _.map x...

  _.unique = (x...) -> _.uniq x...

  _.ucmap = (x...) ->
    _.unique _.compact _.map x...

  async = _.async = require 'async'

  _.par = async.parallel
  _.parl = async.parallelLimit
  _.series = async.series

  _.fns = _.functions
  _.vals = _.values

  fs = require 'fs'

  _.reads = fs.readFileSync
  _.writes = fs.writeFileSync

  _.base = require('path').basename
  _.resolve = require('path').resolve

  _.isDir = _.is_dir = (f) ->
    stat = fs.statSync f
    return stat.isDirectory() if stat
    no

  _.isFile = _.is_file = (f) ->
    stat = fs.statSync f
    return stat.isFile() if stat
    no

  _.every = (x...) -> require('every-time-mirror')(x...)

  _.in = (str,fn) ->
    result = require('english-time-mirror')(str)
    setTimeout fn,result

  _.secs = _.seconds = (str) ->
    result = require('english-time-mirror')(str)
    Math.round(parseInt(result/1000))

  _.type = (o) ->
    return no if o in ['undefined',null]
    Object::toString.call(o).slice(8,-1).toLowerCase()

  _.uuid = require 'time-uuid'

  _.stats = fs.statSync
  _.exists = fs.existsSync

  _.md5 = (x) ->
    c = require('crypto').createHash 'md5'
    c.update x
    c.digest 'hex'

  _.b64_encode = _.b64 = (str) ->
    new Buffer(str).toString 'base64'

  _.b64_decode = (str) ->
    new Buffer(str,'base64').toString 'ascii'

  _.time = ->
    d = new Date().getTime()/1000
    Math.round d

  _.today = (unix_input=null) ->
    d = new Date
    d = new Date (unix_input * 1000) if unix_input
    d.setHours 0, 0, 0, 0
    Math.round(d.getTime()/1000)

  _.yesterday = (unix_input=null) ->
    d = new Date
    d = new Date (unix_input * 1000) if unix_input
    day = _.today(d.getTime()/1000) - _.secs('2 hours')
    _.today day

  _.hour = (unix_input=null) ->
    d = new Date
    d = new Date (unix_input * 1000) if unix_input
    d.setHours new Date().getHours(), 0, 0, 0
    Math.round(d.getTime()/1000)

  _.minute = (unix_input=null) ->
    d = new Date
    d = new Date (unix_input * 1000) if unix_input
    d.setMinutes new Date().getMinutes(), 0, 0
    Math.round(d.getTime()/1000)

  _.week = (unix_input=null) ->
    d = new Date
    d = new Date (unix_input * 1000) if unix_input
    d.addDays(-1) while d.getDay() isnt 1
    d.clearTime()
    d.getTime()/1000

  _.month = (unix_input=null) ->
    d = new Date
    d = new Date (unix_input * 1000) if unix_input
    d.setDate 1
    d.setHours 0, 0, 0, 0
    Math.round(d.getTime()/1000)

  _.mime = (x...) -> require('mime').lookup(x...)

  _.rand = (min,max) ->
    [min, max] = [max, min] if min > max
    Math.floor(Math.random() * (max - min + 1) + min)

  _.random_string = (length=32,pool) ->
    if !pool
      pool = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".split ''
    str = ''; for x in [1..length]
      pool = _.shuffle pool
      str += pool[0]
    str

  _.is_email = (x) -> (/\S+@\S+\.\S+/).test x

  _.enc = (x,salt) ->
    ec = require('easycrypto').getInstance()
    ec.encrypt JSON.stringify(x), salt or '2reh9zmtlsfy5gbi'

  _.dec = (x,salt) ->
    ec = require('easycrypto').getInstance()
    JSON.parse ec.decrypt(x, salt or '2reh9zmtlsfy5gbi')

  _.redis = (uri) ->
    Redis = require 'ioredis'

    if uri
      uri = "redis://#{uri}" if !uri.includes '://'
      parts = require('url').parse uri
      new Redis (parts.port ? 6379), parts.hostname
    else
      new Redis

  _.memcached = _.memcache = _.mem = (uri) ->
    Memcached = require 'memcached'

    if uri
      uri = "memcached://#{uri}" if !uri.includes '://'
      parts = url.parse uri
      new Memcached "#{parts.hostname}:#{parts.port or '11211'}"
    else
      new Memcached "localhost:11211"

  portrange = 45032

  _.port = (cb) ->
    port = portrange
    portrange += 1

    server = net.connect port, ->
      server.destroy()
      _.port cb

    server.on 'error', ->
      return cb port

  _.weight = (arr) ->
    class Weighter
      items: []
      constructor: ->
      add: (item,weight) -> @items.push {item:item,weight:weight}
      pick: ->
        t = 0
        t += x.weight for x in @items
        rand = _.rand(1,t)
        cur = 1
        for x in @items
          if rand in [cur...(cur + x.weight)]
            return x.item
          else
            cur += x.weight
        try return @items[0].item

    w = new Weighter

    for x in arr
      w.add x, (x.weight or 1)

    w.pick()

  _.arg = (str) ->
    a = process.argv.slice 2

    i = 0

    for x in a
      base = x.split('-').join ''

      if base is str
        exists = yes
        if next = a?[i+1]
          if next.substr 0,1 isnt '-'
            value = next
            break
      ++ i

    if exists? and !value?
      yes
    else if exists? and value?
      value
    else
      no

  needle = _.needle = require 'needle'

  _.get = (x...) -> needle.get x...
  _.post = (x...) -> needle.post x...

  return _

if process.env.TAKY_DEV
  console.log '---'

  weg = wegweg()

  log weg.seconds '3 days'
  log weg.base '/wojf/wefoj/wefoj.png'
  log weg.uuid()
  log weg.mime 'image.png'
  log weg.enc 'hello'
  log (weg.cmap [1,2,3,4,5], (x) ->
    if x in [1,2,3] then return null
    x
  )

  await weg.get 'http://example.com', defer e,r
  log e
  log r


