# vim: set expandtab tabstop=2 shiftwidth=2 softtabstop=2
require('iced-coffee-script').register()
_ = require 'lodash'

root = global ? root

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

  _.reads = (x) -> fs.readFileSync(x).toString()
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
    (setTimeout fn,result)

  _.secs = _.seconds = (str) ->
    result = require('english-time-mirror')(str)
    Math.round(parseInt(result/1000))

  _.type = (o) ->
    return no if o in ['undefined',null]
    Object::toString.call(o).slice(8,-1).toLowerCase()

  _.uuid = -> (require 'shortid').generate()

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

  _.mongo = _.mongodb = ((uri) ->
    mongo = require 'mongojs'

    db = mongo uri
    db.uri = do ->
      obj = _.parse_uri uri
      if uri.match '@'
        up = uri.split('@')[0] + '@'
      else
        up = ''
      database = uri.split('/').pop()
      "mongodb://#{up}#{obj.hostname}:#{obj.port or 27017}#{'/' + database or ''}"

    db.mid = (str) ->
      if _.isString str
        return mongo.ObjectId str
      str

    db.find = (coll,options...,cb) ->
      [query,fields,extra] = options
      db.collection(coll).find(query or {}, fields or [], cb)

    db.findOne = (coll,options...,cb) ->
      [query,fields,extra] = options
      if query?._id? then query._id = mongo.ObjectId query._id
      db.collection(coll).findOne (query or {}), fields or [], extra or {}, cb

    db.insert = (coll,doc,cb) ->
      db.collection(coll).insert doc, cb

    db.update = (coll,options...,cb) ->
      [query,update,extra] = options
      db.collection(coll).update (query or {}), update or {}, extra or {}, cb

    db.count = (coll,options...,cb) ->
      [query] = options
      db.collection(coll).count (query or {}), cb

    db.remove = (coll,options...,cb) ->
      [query,just_one] = options
      db.collection(coll).remove (query or {}), just_one or false, cb

    db.distinct = (coll,field,options...,cb) ->
      [extra] = options
      db.collection(coll).distinct field, extra or {}, cb

    db
  )

  _.redis = (uri) ->
    Redis = require 'ioredis'

    if uri
      uri = "redis://#{uri}" if !uri.includes('://')
      parts = require('url').parse uri
      new Redis (parts.port ? 6379), parts.hostname
    else
      new Redis

  _.memcached = _.memcache = _.mem = (uri) ->
    Memcached = require 'memcached'

    if uri
      uri = "memcached://#{uri}" if !uri.includes('://')
      parts = require('url').parse uri
      new Memcached "#{parts.hostname}:#{parts.port ? '11211'}"
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

  _.app = ((opt={}) ->
    express = require 'express'

    # allow passing of preexisting express instance
    app = opt.app ? opt.express ? express()
    app.disable 'x-powered-by'

    if opt.body_parser
      body_parser = require 'body-parser'

      app.use body_parser.urlencoded({
        extended: no
      })

      app.use body_parser.json()

    app.use (req,res,next) ->
      if (tmp = req.headers['x-forwarded-for'])
        req.real_ip = tmp.split(',').shift().trim()
      else
        req.real_ip = req.ip
      next()

    if opt.static
      val = opt.static
      val = [val] if _.type(val) is 'string'
      for dir in val
        base_dir = _.base(dir)
        app.use "/#{base_dir}", (require('serve-static')("./#{base_dir}"))

    return app
  )

  _.minify = ((code) ->
    Ugly = require 'uglify-js'

    toplevel = Ugly.parse code, toplevel:toplevel
    toplevel.figure_out_scope()

    compressor = Ugly.Compressor {warnings:no}
    toplevel = toplevel.transform compressor

    toplevel.figure_out_scope()
    toplevel.compute_char_frequency()
    toplevel.mangle_names {}

    stream = Ugly.OutputStream {}
    toplevel.print stream

    stream.toString() + ''
  )

  _.parse_uri = ((uri) ->
    if num = parseInt(uri) > 1
      return {hostname:'localhost',port:uri}
    if !uri.includes('://')
      uri = "lala://#{uri}"
    parts = require('url').parse uri
    {hostname:parts.hostname,port:parts.port}
  )

  _.emitter = _.events = _.eve = (->
    EventEmitter2 = require('eventemitter2').EventEmitter2

    opt =
      wildcard: yes
      delimiter: ':'
      maxListeners: 9999

    emitter = new EventEmitter2 opt
    emitter.setMaxListeners 9999
    emitter
  )

  _.ucfirst = ((str) ->
    if str and str isnt ''
      str.slice(0,1).toUpperCase() + str.slice(1,str.length)
  )

  _.ucwords = ((str) ->
    if str? and str isnt ''
      arr = str.split ' '
      w = ''; for x in arr
        w += x.slice(0,1).toUpperCase() + x.slice(1,x.length) + ' '
      w.trim()
  )

  _.uri_title = ((str,dash,max_len) ->
    if !dash then dash = '-'
    if !max_len then max_len = 50

    str = str.toLowerCase().trim()
    str = str.replace /[^a-z0-9]/g, ' '

    while str.includes('  ')
      str = str.replace '  ', ' '

    if str.length > max_len
      str = str.slice(0,max_len)

    str.trim().replace /\s/g, dash
  )

  _.pixel = (->
    p = 'R0lGODlhAQABAIAAAP///wAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=='
    (new Buffer p, 'base64')
  )

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
  log r.body

  ###
  app = weg.app({
    static: './build'
    body_parser: yes
  })

  app.listen 8081
  log ":8081"
  ###

  log weg.minify(_.reads './build/module.js')

  db = weg.mongo 'localhost/wegweg-test'
  log weg.fns(db)

  log weg.ucfirst('john')
  log weg.ucwords('john smith')
  log weg.uri_title('john smith\'s newest fantastic post')

