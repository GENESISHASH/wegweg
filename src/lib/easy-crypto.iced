# @https://github.com/mrmarbles/easycrypto/blob/master/lib/easy_crypto.js
crypto = require('crypto')
algorithm = undefined

EasyCrypto = (config) ->
  algorithm = config.algorithm or 'aes-256-cbc'
  return

EasyCrypto::encrypt = (str, pwd) ->
  cipher = crypto.createCipher(algorithm, pwd)
  encrypted = cipher.update(str, 'utf8', 'hex')
  encrypted += cipher.final('hex')
  encrypted

EasyCrypto::decrypt = (str, pwd) ->
  decipher = crypto.createDecipher(algorithm, pwd)
  decrypted = decipher.update(str, 'hex', 'utf8')
  decrypted += decipher.final('utf8')
  decrypted

exports.getInstance = (config) ->
  new EasyCrypto(config or {})
