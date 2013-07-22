module.exports = exports = (req, res, next) ->
  if req.session.currentUserId and req.session.currentUserId == req.param('id')
    next()
  else
    res.redirect '/'
