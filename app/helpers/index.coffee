module.exports = (req, res, next) ->
  require('./helpers')(req, res)
  next()
